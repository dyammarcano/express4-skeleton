FROM runnable/node
RUN rm -rf /root/*
ADD . /root
RUN cd /root && npm install && bower install && npm install --only=dev && gulp coffee && gulp stylus && npm start