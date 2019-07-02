docker run \
-it --rm \
--name airflow \
-v /etc/hosts:/etc/hosts:ro \
-e S3_URL="https://ds2.capetown.gov.za" \
-e S3_KEY=TDEPIHGI11AFDR61ZWKZ \
-e S3_SECRET=U67jiE1tjYwlg/aB8Th4vDBnjmn2xQSIjD+huHGq \
-p 8080:8080 airflow

