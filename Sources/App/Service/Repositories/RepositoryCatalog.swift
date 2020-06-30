//
//  File.swift
//  
//
//  Created by laijihua on 2020/5/6.
//

import Vapor
import Fluent

protocol RepositoryCatalog: Repository {

    func findBy(menuPid: UUID?) -> EventLoopFuture<[Catalog]>

    func findBy(menuId: UUID?) -> EventLoopFuture<Catalog?>

    func saveBy(menu: Catalog) -> EventLoopFuture<Catalog>

    func removeBy(menu: Catalog) -> EventLoopFuture<Void>

    func findMenuTree() -> EventLoopFuture<[OutputCatalog]>
    func findMenuTreeAt(catalogId: UUID) -> EventLoopFuture<[OutputCatalog]>
}

struct DatabaseRepositoryCatalog: RepositoryCatalog, DatabaseRepository {


    let database: Database

    /// 获取菜单 Pid 的菜单
    func findBy(menuPid: UUID?) -> EventLoopFuture<[Catalog]> {
        return Catalog
            .query(on: database)
            .filter(\.$parentCatalog.$id == menuPid)
            .sort(\.$order, .descending)
            .all()
    }

    /// 根据编号查询菜单
    func findBy(menuId: UUID?) -> EventLoopFuture<Catalog?> {
        return Catalog.find(menuId, on: database)
    }

    /// 新增/修改菜单
    func saveBy(menu: Catalog) -> EventLoopFuture<Catalog> {
        if let pid = menu.$parentCatalog.id {
            return Catalog.find(pid, on: database)
                .unwrap(or: ApiError(code: .catalogNotExist))
                .flatMap { parentM in
                    menu.level = parentM.level + 1
                    if let _ = menu.id {
                        // 更新
                        return menu.update(on: self.database).map { menu }
                    } else {
                        // 添加
                        return menu.create(on: self.database).map { menu }
                    }
            }

        } else {
            menu.level = 0
            return menu.save(on: database).map { menu }
        }
    }

    // 删除菜单
    func removeBy(menu: Catalog) -> EventLoopFuture<Void> {
        return menu.delete(on: database)
    }

    func findMenuTree() -> EventLoopFuture<[OutputCatalog]> {
        return Catalog.query(on: database).all().map { menus in
            let tree = menus.compactMap { OutputCatalog(catalog: $0) }
            return self.getMenuTree(menusRoot: tree)
        }
    }

    /// 获取组装好的菜单, 以树的形式显示
    func getMenuTree(menusRoot: [OutputCatalog], pid: UUID? = nil) -> [OutputCatalog] {
        return menusRoot.filter { $0.pid == pid }.sorted(by: { (a, b) -> Bool in
            return a.order < b.order
        })
            .compactMap { menu in
                var menu = menu
                menu.child = self.getChildTree(menuId: menu.id!, menusRoot: menusRoot)
                return menu
        }
    }

    /// 获取菜单的子菜单
    func getChildTree(menuId: UUID, menusRoot: [OutputCatalog]) ->  [OutputCatalog] {
        return menusRoot
            .filter { $0.pid != nil && $0.pid == menuId }
            .filter { $0.id != nil }
            .sorted(by: { (a, b) -> Bool in
                return a.order < b.order
            })
            .compactMap { menu in
                var menu = menu
                menu.child = self.getChildTree(menuId: menu.id!, menusRoot: menusRoot)
                return menu
        }
    }

    /// 获取指定菜单
    func findMenuTreeAt(catalogId: UUID) -> EventLoopFuture<[OutputCatalog]> {
        return Catalog.query(on: database)
            .all()
            .map { menus in
                let tree = menus.filter{ catalog in
                    let ids = catalog.path?.split(separator: ",").map{ UUID(String($0))} ?? []
                    return ids.contains(catalogId)
                }.map { return OutputCatalog(catalog: $0) }
                return self.getMenuTree(menusRoot: tree, pid: catalogId)
        }
    }
}


extension Application.Repositories {
    var catalogs: RepositoryCatalog {
        guard let factory = storage.makeCatalogRepository else {
            fatalError("EmailToken repository not configured, use: app.repositories.use")
        }
        return factory(app)
    }

    func use(_ make: @escaping (Application) -> (RepositoryCatalog)) {
        storage.makeCatalogRepository = make
    }
}
