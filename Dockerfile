FROM daviot1303/kafka-environment:latest
EXPOSE 9092-9100:9092
EXPOSE 8080-8088:8080
COPY . .
RUN chmod -R 777 .
RUN export PATH=$PATH:/root/home/args-container.sh
ENTRYPOINT [ "./args-container.sh" ]
