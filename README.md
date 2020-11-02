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
![](http://blog.loveli.site/mweb/wechat-logo.png)


