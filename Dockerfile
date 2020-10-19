FROM gcc:9.3.0 AS builder

RUN apt-get update && apt-get -y install cmake

COPY . /build/
RUN mkdir /build/build.paho
WORKDIR /build/build.paho

RUN cmake ..
RUN make
RUN ctest -VV --timeout 600

RUN cd ../MQTTSNGateway \
	&& make SENSORNET="udp" \
	&& make test \
	&& cd GatewayTester \
    && make  


FROM debian:9.13
#RUN apk --no-cache add ca-certificates
WORKDIR /opt
COPY --from=builder /build/MQTTSNGateway/Build/MQTT-SNGateway .
COPY --from=builder /build/MQTTSNGateway/gateway.conf .

EXPOSE 8080
ENTRYPOINT ["/opt/MQTT-SNGateway"]