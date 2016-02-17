FROM gliderlabs/alpine:latest

ENV PACKAGES build-base git libcrypto1.0 py-pip python ruby ruby-bundler ruby-dev ruby-json ruby-libs ruby-io-console ruby-bigdecimal
ENV PACKAGES_CLEANUP build-base git py-pip py-setuptools

ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_PATH="$GEM_HOME" \
    BUNDLE_BIN="$GEM_HOME/bin" \
    BUNDLE_SILENCE_ROOT_WARNING=1 \
    BUNDLE_APP_CONFIG="$GEM_HOME"
ENV PATH $BUNDLE_BIN:$PATH
RUN mkdir -p "$GEM_HOME" "$BUNDLE_BIN" && \
    chmod 755 "$GEM_HOME" "$BUNDLE_BIN"

# Install neccessary packages to build fake_sns
RUN apk --update --no-cache add ${PACKAGES}

# Install awscli
RUN pip install awscli

COPY Gemfile /

# Skip installing gem documentation
RUN echo 'gem: --no-rdoc --no-ri' >> "${HOME}/.gemrc"

# Build fakesns
RUN bundle install

# Cleanup
RUN apk --purge -v del ${PACKAGES_CLEANUP} && \
    rm -vfr /usr/share/ri && \
    rm /var/cache/apk/*

RUN mkdir -p /messages/sns && \
    chown -R nobody:nobody /messages/sns/

USER nobody

VOLUME /messages/sns

EXPOSE 9292

# Note: We use thin, because webrick attempts to do a reverse dns lookup on every request
# which slows the service down big time.  There is a setting to override this, but sinatra
# does not allow server specific settings to be passed down.
CMD [ "sh", "-c", "fake_sns --bind 0.0.0.0 --database=/messages/sns/database.yml --port 9292 --server thin" ]
