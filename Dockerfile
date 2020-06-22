FROM registry.suse.com/suse/sle15

RUN zypper addrepo http://smt.example.com/repo/SUSE/Products/SLE-Module-Basesystem/15-SP1/x86_64/product/ SLE-Module-Basesystem
RUN zypper addrepo http://smt.example.com/repo/SUSE/Products/SLE-Module-Containers/15-SP1/x86_64/product/ SLE-Module-Containers
RUN zypper addrepo http://smt.example.com/repo/SUSE/Products/SLE-Module-Development-Tools/15-SP1/x86_64/product/ SLE-Module-Development-Tools 

RUN zypper update

RUN zypper in -y sudo unzip 

RUN sudo zypper install -y glibc-32bit libasan4 libatomic1 libcilkrts5 libitm1 liblsan0 libmpx2 libmpxwrappers2 libtsan0 libubsan0 linux-glibc-devel libgcc_s1-32bit libitm1-32bit glibc-devel libstdc++6-32bit libstdc++6-devel-gcc7 gcc7 gcc7-c++ gcc gcc-c++ libgomp1-32bit libmpx2-32bit libmpxwrappers2-32bit glibc-devel-32bit libasan4-32bit libatomic1-32bit libcilkrts5-32bit libubsan0-32bit libstdc++6-devel-gcc7-32bit gcc-32bit gcc-c++-32bit gcc7-32bit gcc7-c++-32bit


ADD  ./InstalMgr1.5.2_LNX_X86_WAS_8.5.zip /tmp

ADD ./WAS_v8.5.zip /tmp

RUN mkdir /tmp/im &&  unzip -qd /tmp/im /tmp/InstalMgr1.5.2_LNX_X86_WAS_8.5.zip

ARG user=was

ARG group=was

RUN groupadd $group && useradd $user -g $group -m\
    && chown -R $user:$group /var /opt /tmp

USER $user

#RUN mkdir /tmp/was  && unzip  -qd /tmp/was /tmp/WAS_v8.5.zip

RUN chmod -R 775 /var /opt /tmp

###################### IBM Installation Manager ##########################

# Install IBM Installation Manager
RUN /tmp/im/installc -acceptLicense -accessRights nonAdmin  -installationDirectory "/opt/IBM/InstallationManager" -dataLocation "/var/ibm/InstallationManager" -showProgress


################# IBM WebSphere Application Server ######################

# Install IBM WebSphere Application Server v855
RUN /opt/IBM/InstallationManager/eclipse/tools/imcl -showProgress -acceptLicense install com.ibm.websphere.BASE.v85 -repositories /tmp/was/repository.config -installationDirectory /opt/IBM/WebSphere/AppServer

# create IBM WebSphere Application Server profile

ARG PROFILE_NAME=AppSrv01

ARG CELL_NAME=ServerCell

ARG NODE_NAME=ServerNode

ARG HOST_NAME=localhost

# Create default AppServer profile
RUN /opt/IBM/WebSphere/AppServer/bin/manageprofiles.sh -create -templatePath /opt/IBM/WebSphere/AppServer/profileTemplates/default -profileName $PROFILE_NAME -profilePath /opt/IBM/WebSphere/AppServer/profiles/$PROFILE_NAME -cellName $CELL_NAME -nodeName $NODE_NAME -hostName $HOST_NAME

#Expose the ports 
EXPOSE 9060 9043 9080 9443 2809 5060 5061 8880 9633 9401 9403 9402 9100 9353 7276 7286 5558 5578 11003 11004

ENV PATH /opt/IBM/WebSphere/AppServer/bin:$PATH

RUN rm -fr /tmp/InstalMgr1.5.2_LNX_X86_WAS_8.5.zip /tmp/im && rm -fr /tmp/was /tmp/WAS_v8.5.zip
