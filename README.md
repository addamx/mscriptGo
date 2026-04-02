# 开发

## 安装依赖
go mod tidy

## 构建
go build -o ./bin/mscript.exe

## 运行
./bin/mscript.exe


## release
export GITHUB_TOKEN=你的token
bash scripts/release.sh v0.1.0


# install
curl -fsSL https://raw.githubusercontent.com/addamx/mscriptGo/master/install.sh | bash
