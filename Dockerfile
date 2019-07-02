from ubuntu

# Noninteractive mode
ENV DEBIAN_FRONTEND noninteractive

# Expose the server port
EXPOSE 8080 5555 8793

# Sorting timezone 
ENV TZ "Africa/Johannesburg"
RUN DEBIAN_FRONTEND=noninteractive && \
  echo $TZ > /etc/timezone && \
  apt-get update && \
  apt-get install -y tzdata locales && \
  rm /etc/localtime && \
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
  dpkg-reconfigure -f noninteractive tzdata

# Define en_ZA
RUN sed --in-place '/en_ZA.UTF-8/s/^# //' /etc/locale.gen && \
  locale-gen en_ZA && \
  locale-gen en_ZA.UTF-8 && \
  dpkg-reconfigure --frontend=noninteractive locales && \
  update-locale
#  Setting appropriate location-specific variables
ENV LANGUAGE en_ZA.UTF-8
ENV LANG en_ZA.UTF-8
ENV LC_ALL en_ZA.UTF-8
ENV LC_CTYPE en_ZA.UTF-8
ENV LC_MESSAGES en_ZA.UTF-8
ENV AIRFLOW__CORE__DEFAULT_TIMEZONE "Africa/Johannesburg"

# Install required packages
RUN apt-get update && \
apt-get install -y curl nano python3-pip postgresql postgresql-contrib

# Install required python packages
RUN pip3 install apache-airflow[postgres,kubernetes] docker

# Airflow args
ARG AIRFLOW_VERSION=1.10.3
ARG AIRFLOW_USER_HOME=/usr/local/airflow
ARG AIRFLOW_DEPS=""
ARG PYTHON_DEPS=""
ENV AIRFLOW_HOME=${AIRFLOW_USER_HOME}

# Cleanup
RUN apt-get purge --auto-remove -yqq $buildDeps \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base

# Create airflow user
RUN useradd -ms /bin/bash -d ${AIRFLOW_USER_HOME} airflow
RUN chown -R airflow: ${AIRFLOW_USER_HOME}
# Drop to airflow user
USER airflow
WORKDIR ${AIRFLOW_USER_HOME}

# Install minio client
RUN mkdir ~/mc
RUN curl -o ~/mc/mc https://dl.min.io/client/mc/release/linux-amd64/mc
RUN chmod +x ~/mc/mc
ENV PATH="~/mc:${PATH}"

# Configure minio client
ENV S3_URL=""
ENV S3_KEY=""
ENV S3_SECRET=""

# Creating a DAGs dir in the airflow user's directory
RUN mkdir dags

# Copy in start script 
COPY airflow.cfg .
COPY start.sh .
#RUN chmod +x start.sh

# Initialize database
#RUN airflow initdb
CMD ["/bin/bash", "./start.sh"]
