FROM gliderlabs/alpine:3.3

# add neccessary packages
RUN apk --update --no-cache add \
    ruby \
    ruby-bundler \
    groff \
    less \
    python \
    py-pip

# install awscli
RUN pip install awscli

# cleanup
RUN apk --purge -v del py-pip

COPY Gemfile /Gemfile

# build fakesns
RUN bundle install

EXPOSE 9292

# Note: We use thin, because webrick attempts to do a reverse dns lookup on every request
# which slows the service down big time.  There is a setting to override this, but sinatra
# does not allow server specific settings to be passed down.
CMD fake_sns --bind 0.0.0.0 --database=/messages/sns/database.yml --port 9292 --server thin
