#!/bin/bash
# 顏色設定
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
WHITE="\033[0m"

# 取得目前 shell script 檔案的路徑($0)的目錄
BASEDIR=$(dirname "$0")
echo $BASEDIR

# echo -e 開啟轉義
echo -e "${BLUE}請輸入部署的 release name:${WHITE}"
read release_name
if [ -z "$release_name" ]; then
  echo -e "${RED}release name 不能為空${WHITE}"
  exit 1
fi

echo -e "${BLUE}選擇部署用的 helm chart:${WHITE}"
read chart_name
if [ -z "$chart_name" ]; then
  echo -e "${RED}chart 不能為空${WHITE}"
  exit 1
fi

echo -e "${BLUE}選擇部署環境 env name:${WHITE}"
read env_name
if [ -z "$env_name" ]; then
  echo -e "${RED}env name 不能為空${WHITE}"
  exit 1
fi


# talkto helm
function helm_output_k8s_yaml(){
  # 依據變數選擇叢集
  case $env_name in
    dev)
      ctx="gke-dev"
      ;;
    qa)
      ctx="gke-qa"
      ;;
    prod)
      ctx="gke-prod"
      ;;
    *)
      echo -e "${RED}env name:${env_name}，未找到部署的叢集${WHITE}"
      exit 1
      ;;
  esac

  # 輸出當前叢集
  echo -e "${YELLOW}當前叢集: ${ctx}${WHITE}"

  # helm template 單純輸出 yaml，不會跟 dry-run 一樣會跟線上資源衝突。
  # 輸出的 yaml 寫到 k8s.yaml
  helm template --namespace default --kube-context ${ctx} $release_name ./$chart_name/ -f ./$chart_name/values/$env_name.yaml > ./k8s.yaml

  # 比對線上資源與輸出的 yaml 差異
  kubectl diff -f ./k8s.yaml
}

# 執行
helm_output_k8s_yaml