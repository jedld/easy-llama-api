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


```
bundle
```

Running
========

Run sinatra
```
ruby app.rb
```