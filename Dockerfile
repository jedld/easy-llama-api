FROM ubuntu:22.04
RUN sudo apt-get update
RUN apt-get install build-essential intel-opencl-icd -y

