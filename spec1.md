# 这是go语言构建cli项目，名字叫 mscript，提供一些服务器常用功能，如安装python、nodejs

## 技术栈
- go语言
- cobra库

## 用例
- 输入mscript 后，可以选择，config，install
- 选择config后，可以选择 配置httpProxy
    - 选择 配置 httpProxy 后，可以输入代理地址，默认是http://
    - 输入后会校验地址是否合法
    - 如果不合法，会提示重新输入
    - 如果合法，会增加或替换一下内容到.profile文件，格式如下
    ```
# mscript_httpProxy_start
export GLOBAL_HTTP_PROXY=http://127.0.0.1:10792
proxyon() {
    export http_proxy="$GLOBAL_HTTP_PROXY"
    export https_proxy="$GLOBAL_HTTP_PROXY"
    export ALL_PROXY="$GLOBAL_HTTP_PROXY"
}

proxyoff() {
    unset ALL_PROXY
    unset http_proxy
    unset https_proxy
}
# mscript_httpProxy_end
    ```

