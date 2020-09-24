## boke

vapor4 博客项目

* 前端代码：[swiftdo/boke-flutter](https://github.com/swiftdo/boke-flutter.git)
* 后端代码：[swiftdo/boke](https://github.com/swiftdo/boke.git)
* 在线预览：[https://swiftdo.github.io/boke-flutter](https://swiftdo.github.io/boke-flutter)
  * 测试账号：boke@oldbird.run  boke12345
  
## 功能概要

![func](http://blog.loveli.site/2020-09-06-boke.png)


## 本地部署

为了比较方便部署，隔离本机上一些工具的影响，采用 docker 进行部署。

1. 运行应用：

```sh
$ docker-compose up -d app
```

这样就把项目部署好了，但是数据库的迁移还未发生(如果你代码里没有直接调用迁移方法)，
可在浏览器中输入 `http://localhost:8080`, -> 'It works!';

2. 数据库迁移

```sh
$ docker-compose up -d migrate
```

进行数据库迁移，这样，数据库的改动才会生效

3. 开启 pgadmin 直接访问数据库

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
$ docker-comose up -d pgadmin
```

执行完成后，直接在浏览器中输入 `http://localhost:15000` 就可以进入 pgadmin 的登录页面。
使用 `1164258202@qq.com` 和 `oldbirds` 进行登录。这样就可以愉快的操作 postgresql 数据库了。
