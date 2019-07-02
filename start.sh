if [[ $S3_URL != "" ]]; then
  echo configuring access to s3 object store at $S3_URL...
  mc config host add s3 \
  $S3_URL \
  $S3_KEY \
  $S3_SECRET \
  --api S3v4
  echo copying in dags from dags bucket at $S3_URL...
  mc cp -r s3/dags ~/
fi

airflow initdb

airflow webserver -p 8080 &>/dev/null

/bin/bash
