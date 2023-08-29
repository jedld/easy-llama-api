FROM ubuntu:22.04
RUN apt-get update
RUN apt-get install build-essential intel-opencl-icd clinfo ruby-full git libclblast-dev -y
RUN gem install bundler
RUN bundle config build.llama_cpp --with-clblast=yes
RUN mkdir /usr/app
COPY . /usr/app
WORKDIR /usr/app
RUN bundle
EXPOSE 3100
CMD ruby app.rb