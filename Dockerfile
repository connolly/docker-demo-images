#FROM jupyter/minimal
FROM ubuntu:14.04

USER root

RUN apt-get update
RUN apt-get install -y software-properties-common  build-essential
RUN apt-get install -y git python curl bison flex g++ git libbz2-dev libreadline6-dev libx11-dev libxt-dev m4 zlib1g-dev 
RUN apt-get install -y libfontconfig libxrender1
RUN apt-get install -y wget


#install LSST software as a non user
RUN /usr/sbin/useradd --create-home --home-dir /home/maf --shell /bin/bash maf
USER maf
WORKDIR /home/maf
ENV HOME /home/maf
ENV SHELL /bin/bash
ENV USER maf

# Workaround for issue with ADD permissions
USER root
ADD common/profile_default /home/maf/.ipython/profile_default
ADD common/templates/ /srv/templates/
RUN chmod a+rX /srv/templates
RUN chown maf:maf /home/maf -R
USER maf

EXPOSE 8888


# Build LSST system
USER maf
WORKDIR /home/maf
RUN mkdir -p lsst
RUN cd lsst && curl  -o newinstall.sh https://sw.lsstcorp.org/eupspkg/newinstall.sh && bash newinstall.sh -b


#get updated eups
RUN mkdir /home/maf/eups
RUN cd /home/maf/eups; wget http://eupsforge.net/ipython-eups
RUN cd /home/maf/eups; chmod +x ipython-eups
ENV PATH /home/maf/eups:$PATH

RUN cd /home/maf/; git clone https://github.com/LSST-nonproject/sims_maf_contrib.git


ADD startup.sh /home/maf/
USER root
RUN chmod +x startup.sh 
USER maf
ENV PATH /home/maf/eups:$PATH


#RUN /bin/bash -c "source lsst/loadLSST.bash;  printenv"
ENV PATH /home/maf/lsst/Linux64/anaconda/2.2.0/bin:$PATH

#RUN ls /home/maf/lsst/Linux64/anaconda/2.2.0/bin/
RUN ln -s /home/maf/lsst/eups .eups/default
RUN ls .eups/default
RUN which ipython

CMD ipython-eups notebook
#CMD startup.sh
