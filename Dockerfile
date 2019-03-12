FROM angeliquetaylor/ros:kinetic_cuda 

# install build tools
RUN apt-get update && apt-get install -y \
      python-catkin-tools \
      lsb-release wget less udev sudo apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

RUN wget -O ZED_SDK_Linux_Ubuntu16.run https://download.stereolabs.com/zedsdk/2.7/ubuntu16_cuda9 \
    && echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections \
    && chmod +x ZED_SDK_Linux_Ubuntu16.run ; ./ZED_SDK_Linux_Ubuntu16.run silent\
	&& rm ./ZED_SDK_Linux_Ubuntu16.run

# clone ros package repo
ENV ROS_WS /opt/ros_ws
RUN mkdir -p $ROS_WS/src
WORKDIR $ROS_WS
COPY ./ $ROS_WS/src
#RUN git -C src clone \
#      -b $ROS_DISTRO-devel \
#      https://github.com/ros/ros_tutorials.git

# install ros package dependencies
RUN apt-get update && \
    rosdep update && \
    rosdep install -y \
      --from-paths \
        src \
      --ignore-src && \
    rm -rf /var/lib/apt/lists/*

# build ros package source
RUN catkin config \
      --extend /opt/ros/$ROS_DISTRO && \
    catkin build 
#     roscpp_tutorials

# source ros package from entrypoint
RUN sed --in-place --expression \
      '$isource "$ROS_WS/devel/setup.bash"' \
      /ros_entrypoint.sh

# run ros package launch file
#CMD ["roslaunch", "roscpp_tutorials", "talker_listener.launch"]