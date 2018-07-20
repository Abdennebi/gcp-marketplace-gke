
FROM launcher.gcr.io/google/debian9 AS build

RUN apt-get update \
    && apt-get install -y --no-install-recommends gettext

ADD aqua /tmp/chart

RUN cd /tmp \
    && tar -czvf /tmp/aqua.tar.gz chart
    
#ADD apptest/deployer/nginx /tmp/test/chart
# # RUN cd /tmp/test \
#     && tar -czvf /tmp/test/nginx.tar.gz chart/

ADD schema.yaml /tmp/schema.yaml

# Provide registry prefix and tag for default values for images.
ARG REGISTRY
ARG TAG
RUN cat /tmp/schema.yaml \
    | env -i "REGISTRY=$REGISTRY" "TAG=$TAG" envsubst \
    > /tmp/schema.yaml.new \
    && mv /tmp/schema.yaml.new /tmp/schema.yaml 
FROM gcr.io/cloud-marketplace-tools/k8s/deployer_helm
COPY --from=build /tmp/aqua.tar.gz /data/chart/
COPY --from=build /tmp/schema.yaml /data/
#COPY --from=build /tmp/test/nginx.tar.gz /data-test/chart/
#COPY apptest/deployer/schema.yaml /data-test/

###############
#
# Unnecessary copy from v.0.7
# ADD schema.yaml /data/
# ADD run.sh /opt
# RUN chmod 755 /opt/run.sh
# COPY aqua/ /opt/
# ENTRYPOINT ["/bin/bash", "/opt/run.sh"]
#
###############