![logo](http://blog.loveli.site/2020-09-26-banner.png)

## boke

vapor4 博客项目

* 前端代码：[swiftdo/boke-flutter](https://github.com/swiftdo/boke-flutter.git)
* 客户端：[swiftdo/boke-flutter-native](https://github.com/swiftdo/boke-flutter-native.git)
* 后端代码：[swiftdo/boke](https://github.com/swiftdo/boke.git)
* 在线预览：[https://boke.loveli.site](https://boke.loveli.site)
  * 测试账号：boke@oldbird.run   boke12345
  
## 功能概要

![func](http://blog.loveli.site/2020-09-06-boke.png)

## 本地部署

为了便于部署，隔离本机上的应用环境，采用 `docker` 进行部署。

### 开启

* 下载代码

  ```sh
  git clone https://github.com/swiftdo/boke.git --recursive
  ```

  修改前端页面的请求 `baseurl`，打开文件 `boke-flutter/lib/config/config.dart`, 然后将 `requestBaseURL` 更改为:

  ```dart
  final String requestBaseURL = 'http://127.0.0.1:8080/api';
  ```

* 编译镜像

  ```sh
  docker-compose build
  ```

  因为在编译镜像的时候，会容器内下载一些墙外资源，需要配置下代理，加快依赖的下载。

  如何配置，请查看[Docker 容器内无法使用宿主机的代理配置，咋办?](https://mp.weixin.qq.com/s/MrGkC9P3rP-5GnNzo8_XNQ)

* 运行应用：

  ```sh
  docker-compose up -d app
  ```

  这样就把项目部署好了，但是数据库的迁移还未发生(如果你代码里没有直接调用迁移方法)，
  可在浏览器中输入 `http://localhost:8080`, -> 'It works!';

* 数据库迁移

  ```sh
  docker-compose up -d migrate
  ```

  进行数据库迁移，这样，数据库的改动才会生效。

* 开启前端

  ```sh
  docker-compose up -d web
  ```

  完成后，在浏览器中输入： `http://localhost:8090`，即可访问。

* 开启 pgadmin 直接访问数据库 (非必要步骤)

  ```yml
  # docker-compose.yml

  pgadmin:
    image: dpage/pgadmin4:latest
    volumes:
      - pgadmin-data:/var/lib/pgadmin
    environment:
      PGADMIN_DEFAULT_EMAIL: 1164258202@qq.com
      PGADMIN_DEFAULT_PASSWORD: oldbirds
    ports:
      - "15000:80"
  ```

  上面是 pgadmin 服务的编排配置。
  `PGADMIN_DEFAULT_EMAIL` 和  `PGADMIN_DEFAULT_PASSWORD`  可以自行修改.
  当然，`15000` 端口也可以自定义。

  假设配置不做任何改变。

  ```sh
  docker-compose up -d pgadmin
  ```

  执行完成后，直接在浏览器中输入 `http://localhost:15000` 就可以进入 pgadmin 的登录页面。
  使用 `1164258202@qq.com` 和 `oldbirds` 进行登录。这样就可以愉快的操作 postgresql 数据库了。

### 关闭

关闭的项目，提供 2 种方式：

1. 如果仅仅是**关闭项目**，可以执行：

   ```sh
   docker-compose down
   ```

2. 如果是**关闭项目且删除数据卷(数据库等)**，可以执行：

   ```sh
   docker-compose down -v
   ```
   
## 相关文章
   
* [git submodule](https://oldbird.run/tools/git/t2-git-submodule.html)
* [在 Docker 上部署一个 Flutter Web 应用](https://oldbird.run/flutter/t6-docker-web-deploy.html)



如果想关注更多技术，可以关注公众号：

<img src="http://blog.loveli.site/mweb/wechat-logo.png" width="420" />


## 相关时序图

为了比较好的理解业务流程，整理一些时序图供梳理

### 认证
![](http://blog.loveli.site/mweb/token%20%E8%AE%A4%E8%AF%81.png)


## 基于用户角色的权限系统

在简单的程序中，通常只有两种角色，比如个人博客只有博客作者和匿名的访客。这时我们并不需要在区分角色和管理权限上花太多功夫，可以简单的通过 token 就可以判断角色。登录(有 session 代表是登录用户)的是管理员，未登录的就是访客。

在更复杂的一些程序中，在登录的用户中还需要进一步区分出普通用户和管理员。这时候像过滤未确认用户一样，在 User 模型中添加一个 admin 字段。通过 admin 就可以判断出该用户是否是管理员。

通常大型程序中需要更多的用户角色：拥有最高权限的管理员、负责管理内容的协管员、使用网站提供服务的普通用户、因违规操作而被临时封禁的用户等。每类用户所能进行的操作权限自然不能完全相同，我们需要根据用户的角色赋予不同的权限。比如，普通用户可以上传文章、发表评论，但被临时封禁的用户只能删除和编辑已经上传的文章或删除已发表的评论；协管员除了具有普通用户的所有权限，还可以删除或者屏蔽不当的评论、文章以及违规的用户；管理员权限最大，除了拥有其他角色的权限外；还可以更改用户的角色、管理网站信息、发布系统消息等。

通常这种管理方法被称为 RBAC(Role-Based Access Control, 基于角色的权限控制)。

首先，我们需要创建数据库模型来存储角色和权限数据：

```swift
/// 角色
final class Role: Model {
    static let schema = "roles"

    @ID(key: .id)var id: UUID?
    @Field(key: FieldKeys.name) var name: String

    init(){ }

    init(name: String) {
        self.name = name
    }
}

extension Role {
    struct FieldKeys {
        static var name: FieldKey { "name" }
    }
}
```

```swift
/// 权限
final class Permission: Model {
    static let schema = "roles"
    
    @ID(key: .id)var id: UUID?
    @Field(key: FieldKeys.name) var name: String

    init(){ }

    init(name: String) {
        self.name = name
    }
}

extension Permission {
    struct FieldKeys {
        static var name: FieldKey { "name" }
    }
}
```

在表示角色的 Role 类中，name 字段存储角色的名称。类似的，在表示权限 Permission 类中，name 字段用来存储权限的名称。

每个角色可以拥有多种权限，而每个权限又会被多个角色拥有。角色和权限之间通过关联表  `RolePermission` 建立多对多关系：

```swift
final class RolePermission: Model {

    static let schema = "roles_permissions"

    @ID(key: .id) var id: UUID?
    @Parent(key: FieldKeys.roleId) var role: Role
    @Parent(key: FieldKeys.permissionId) var permission: Permission

    init() {}

    init(roleId: UUID, permissionId: UUID) {
        self.$role.id = roleId
        self.$permission.id = permissionId
    }

}

extension RolePermission {
    struct FieldKeys {
        static var roleId: FieldKey { "role_id" }
        static var permissionId: FieldKey { "permission_id" }
    }
}
```

```swift
final class Role: Model {
    ...
    @Siblings(through: RolePermission.self, from: \.$role, to: \.$permission) var permissons: [Permission]
```

```swift
final class Permission: Model {
    ...
    @Siblings(through: RolePermission.self, from: \.$permission, to: \.$role) var roles: [Role]
```

另外， 每个角色都会有多个用户，Role 模型和 User 模型之间建立了一对多的关系：

```swift
final class User: Model, Content {
    ...
    @Parent(key: FieldKeys.roleId) var role: Role
```

```swift
final class Role: Model {
    ...
    @Children(for: \.$role) var users: [User]
```

在 User 模型中创建 role_id 字段为存储 Role 记录主键值的外键字段。

### 设置角色与权限

不同的程序会拥有不同的角色和权限，下面是定义的几种操作权限。

定义的权限：

| 操作 | 权限名称 | 说明 |
| --- | --- | --- |
| 关注用户 | FOLLOW | 关注其他用户 |
| 收藏文章 | COLLECT | 添加文章到自己的收藏 |
| 发布评论| COMMENT | 在文章下添加评论 |
| 上传文章| UPLOAD | 上传文章 |
| 协管员权限 | MODERATE | 管理资源权限，可以管理网站的用户，文章，评论，标签，分类等资源 |
| 管理员权限 | ADMINISTER | 管理用户角色、编辑网站信息等 |

> 你可以根据自己的程序需要设计权限和角色。比如网站内容管理可能有多个角色分工，这时候上面的 MODERATE 权限就可以细分为 MODERATE_USER、MODERATE_TOPIC 等多个权限。

定义的角色及对应的权限：


| 角色名称 | 拥有权限 | 说明 |
| --- | --- | --- |
| 访客(Guest) | 仅可以浏览页面 | 未登录用户 |
| 被封禁用户(Blocked) | 仅可以浏览页面 | 因违规行为被封禁账号，禁止登录的用户 |
| 被锁定用户(Locked) | FOLLOW\COLLECT | 因违规行为被锁定的用户 |
| 普通用户(User) | FOLLOW\COLLECT\COMMENT\UPLOAD | 注册后用户获得的默认角色 |
| 协管员(Moderator) | 除了拥有普通用户具有的权限外，还拥有 MODERATE 权限 | 除了普通用户的权限外，还拥有管理网站内容的权限，负责网站的内容管理和维护 |
| 管理员(Administrator) | 除了拥有普通用户和协管员的所有权限外，还拥有 ADMINISTER 权限 | 拥有所有权限的网站管理员 |

### 写入角色与权限

一般来说，权限与角色一旦确定，就不会有大的变动，可以直接在程序中预先定义。如果手动写入，太过麻烦，而且在开发环境中随时可能要重新生成数据库，我们可以创建预填充的工作。

在此之前，我们需要把程序中的角色和权限的对应关系保存起来。

```swift
struct ETNameSpace {
    
    enum Permission : CaseIterable {
        case follow
        case collect
        case comment
        case upload
        case moderate
        case administer

        var string: String {
            switch self {
            case .follow: return "FOLLOW"
            case .collect: return "COLLECT"
            case .comment: return "COMMENT"
            case .upload: return "UPLOAD"
            case .moderate: return "MODERATE"
            case .administer: return "ADMINISTER"
            }
        }
    }

    enum Role : CaseIterable {
        case locked
        case user
        case moderator
        case administrator

        var string: String {
            switch self {
            case .locked:
                return "Locked"
            case .user:
                return "User"
            case .moderator:
                return "Moderator"
            case .administrator:
                return "Administrator"
            }
        }
        
        var permissions: [Permission] {
            switch self {
            case .locked: return [.follow, .collect]
            case .user: return [.follow, .collect, .comment, .upload]
            case .moderator: return [.follow, .collect, .comment, .upload, .moderate]
            case .administrator: return ETNameSpace.Permission.allCases
            }
        }
    }
}
```
然后创建迁移：

```swift
struct RolePermissionSeed: Migration {

    func prepare(on database: Database) -> EventLoopFuture<Void> {
        
        let allPers: [ETNameSpace.Permission] = ETNameSpace.Permission.allCases
        let allRols: [ETNameSpace.Role] = ETNameSpace.Role.allCases
        
        let createPermissionFuture = allPers
            .compactMap { permission in
                return Permission(name: permission.string).save(on: database)
            }
            .flatten(on: database.eventLoop)
            
        return createPermissionFuture
            .flatMap { _ -> EventLoopFuture<Void> in
             return allRols
                .compactMap { erole in
                    let role = Role(name: erole.string)
                    return role
                        .save(on: database)
                        .flatMap { _ -> EventLoopFuture<Void> in
                            return erole
                                .permissions
                                .compactMap { epermission in
                                return Permission
                                    .query(on: database)
                                    .filter(\.$name == epermission.string)
                                    .first()
                                    .unwrap(or: ApiError(code: .permissionNotExist))
                                    .flatMap { permission in
                                        return permission.$roles.attach(role, on: database)
                                    }
                            }.flatten(on: database.eventLoop)
                        }
                }.flatten(on: database.eventLoop)
            }

    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.eventLoop.flatten([
            Role.query(on: database).delete(),
            Permission.query(on: database).delete(),
        ])
    }
}
```

```swift
....
app.migrations.add(CreateRole())
app.migrations.add(CreatePermission())
app.migrations.add(CreateRolePermission())
app.migrations.add(RolePermissionSeed())
app.migrations.add(UserAddRoleId())
```
执行迁移：

```sh
$ vapor run migrate
```

我们需要让用户在注册时就获得角色，也就是与对应的角色建立关系，所以在注册的方法里：

```swift
private func register(_ req: Request) throws -> EventLoopFuture<OutputJson<OutputCreate>> {
        ...
        .flatMap { user in
            return req.repositoryUsers.create(user).map { user }
        }
        .flatMap { user -> EventLoopFuture<User> in
            if user.$role.id == nil {
                var roleType = ETNameSpace.Role.user
                if (user.email == req.myConfig.adminEmail) {
                    roleType = ETNameSpace.Role.administrator
                }
                return Role
                    .query(on: req.db)
                    .filter(\.$name == roleType.string)
                    .first()
                    .unwrap(or: ApiError(code: .roleNotExist))
                    .flatMap { role in
                        user.$role.id = role.id
                        return user.update(on: req.db)
                    }.map { user }
            }
            return req.eventLoop.makeSucceededFuture(user)
        }
        .and(req.password.async.hash(inputRegister.password))
        ....
```

除了管理员以外，其他用户初始角色都是 "User", 那么我们如何从所有用户中识别出管理员呢？显然，我们可以通过 Email 地址来判断。
每一个用户都拥有独一无二的 Email 地址，因此，我们可以通过判断用户的 Email 地址是否和配置变量 `adminEmail` 设置的值相吻合来识别管理员，
进而对用户设置不同的角色----通过关系属性 User.role 与对应的 Role 记录建立关系。


### 验证用户权限

判断某个用户是否拥有某项权限，实际上就是判断该用户在数据库中对应的角色记录关联的权限记录中是否包含该项权限。我们可以获取某个用户角色记录和对应的权限记录列表:

```swift

func permissions(id: UUID?) -> EventLoopFuture<[Permission]> {
    return User
        .find(id, on: database)
        .unwrap(or: ApiError(code: .userNotExist))
        .flatMap { user in
            user.$role.get(on: database).unwrap(or: ApiError(code: .roleNotExist))
        }
        .flatMap { (role: Role) in
            role.$permissons.get(on: database)
        }
}
```
验证权限的过程也简单，假设我们现在要在验证该用户是否有上传的权限，首先应获取权限对象。

```swift

func can(id: UUID?, permission: ETNameSpace.Permission) throws -> EventLoopFuture<Bool> {
    let permissionId = Permission
        .query(on: database)
        .filter(\.$name == permission.string)
        .first()
        .unwrap(or: ApiError(code: .permissionNotExist))
        .flatMapThrowing { try $0.requireID() }
        
    return User
        .find(id, on: database)
        .unwrap(or: ApiError(code: .userNotExist))
        .flatMap { user in
            user.$role.get(on: database).unwrap(or: ApiError(code: .roleNotExist))
        }
        .and(permissionId)
        .flatMap { (role: Role, perId: UUID) in
            role.$permissons.query(on: database).filter(\.$id == perId).count().map{ $0 > 0 }
        }
}
```

在路由中，我们希望接口只允许符合某个权限才允许访问，那么我们可以创建个中间件 PermissionMiddleware:

```swift
import Vapor
import Fluent

protocol PermissionFilterable: Model, Authenticatable {
    static var roleKey: KeyPath<Self, OptionalParent<Role>> { get }
}

extension PermissionFilterable {
    
    public static func permissionMiddleware(
        _ permission: ETNameSpace.Permission
    ) -> Middleware {
        PermissionFilterMiddleware<Self>(permission: permission)
    }
    
    var _$role: OptionalParent<Role> {
        self[keyPath: Self.roleKey]
    }
}


private struct PermissionFilterMiddleware<A>: Middleware
    where A: PermissionFilterable
{
    public let permission: ETNameSpace.Permission
    
    func respond(to req: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        guard let user = req.auth.get(A.self) else {
            return req.eventLoop.makeFailedFuture(Abort(.unauthorized, reason: "\(Self.self) not authenticated."))
        }
        
        let permissionId = Permission
            .query(on: req.db)
            .filter(\.$name == permission.string)
            .first()
            .unwrap(or: ApiError(code: .permissionNotExist))
            .flatMapThrowing { try $0.requireID() }
        
        return user._$role.get(on: req.db)
            .unwrap(or: ApiError(code: .roleNotExist))
            .and(permissionId)
            .flatMap { (role: Role, perId: UUID) in
                role.$permissons.query(on: req.db).filter(\.$id == perId).count()
            }
            .guard({ $0 > 0 }, else: ApiError(code: .permissionInsufficient))
            .flatMap { _ in
                next.respond(to: req)
            }
    }
}
```

然后在使用的地方加入这个中间件即可：

```swift
func boot(routes: RoutesBuilder) throws {
    routes.group("app") { appGroup in
        let authGroup = appGroup.grouped(AccessToken.authenticator(), User.guardMiddleware())
        
        let adminGroup = authGroup.grouped(User.permissionMiddleware(.administer))
        adminGroup.get("hello") { req in
            return "admin say hello"
        }
    }
}
```








