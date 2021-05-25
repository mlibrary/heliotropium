#Start with Ruby 2.7.2 Image
FROM ruby:2.7.2

#Set up variables for creating a user to run the app in the container
ARG UNAME=app
ARG UID=1000
ARG GID=1000

#This is so rails can install properly
RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  apt-transport-https

#Download node at the preferred version; Download Yarn
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN curl https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Install Node and Vim. Vim is optional, but can be nice to be able to look 
# to be able to actually look at files in the container.
RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  nodejs \
  yarn \
  vim

#So we can bundle install
RUN gem install bundler:2.1.4

#Create the group for the user
RUN groupadd -g ${GID} -o ${UNAME}

#Create the User and assign /app as its home directory
RUN useradd -m -d /app -u ${UID} -g ${GID} -o -s /bin/bash ${UNAME}


#Create a /gems directory; Putting it here makes it easer to create a gems volume.
RUN mkdir -p /gems && chown ${UID}:${GID} /gems

#Change to that User; Waited until this step because the app user doesn't
#have the authority to great the /gems directory that was done above.
USER $UNAME

#Tell bundler to use the /gems directory
ENV BUNDLE_PATH /gems

#Copy the Gemfile and Gemfile.lock from the Host machine into the /app directory; 
COPY --chown=${UID}:${GID} Gemfile* /app/

#cd to app
WORKDIR /app

#Install the Gems. Notice that this is done when only Gemfile and 
#Gemfile.lock are in the /app directory
RUN bundle install

#Copy all of the files in the current Host directory into /app
COPY --chown=${UID}:${GID} . /app

#Set up Placeholder Environment Variables; These will be overwritten
#by Docker Compose and in production

#Run the application
CMD ["bin/rails", "s", "-b", "0.0.0.0"]