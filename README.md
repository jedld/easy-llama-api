Introduction
============

I needed a frontend for my dedicated "AI" box that runs small LLMs like the LLAMA 2 13B model.

My dedicated AI box is a 12th gen Intel NUC box, so it has an Intel Xe 80 EU GPU. 

This app provides a quick way to interact with a quantized LLM generated using llama.cpp.

Installation
============

Enable CUDA for llama2.cpp

For those with a Nvidia GPU

```
bundle config build.llama_cpp --with-cublas=yes
bundle
```

For those with an OpenCL supported GPU (e.g. AMD Radeon, Intel Iris etc.)

```
bundle config build.llama_cpp --with-clblas=yes
bundle

```


Running
========

Run sinatra

```
ruby app.rb
```

YOu may then visit the app at port 3100


Running using Docker
====================

```
docker build . -t easyapi:latest
```

Run (For OpenCL and Intel GPUs)

make sure /dev/dri is accessible by the current user


```
docker run -p 3100:3100 -e SERVER_NAME="<SERVER HOST NAME if not localhost>" -v <path to .gguf file>:/data/models/model.bin  --device=/dev/dri  -it easyapi:latest
```