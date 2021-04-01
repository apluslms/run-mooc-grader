DEBUG = True
#SECRET_KEY = 'not a very secret key'
ADMINS = (
)
#ALLOWED_HOSTS = ["*"]

STATIC_ROOT = '/local/grader/static/'
MEDIA_ROOT = '/local/grader/media/'
SUBMISSION_PATH = '/local/grader/uploads'
PERSONALIZED_CONTENT_PATH = '/local/grader/ex-meta'
STATIC_URL_HOST_INJECT = 'http://localhost:8080'

CONTAINER_SCRIPT = '/srv/docker-compose-run.sh'

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': '/local/grader/db.sqlite3',
    }
}

CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
        'LOCATION': 'unique-snowflake',
    },
}

LOGGING['loggers'].update({
    '': {
        'level': 'INFO',
        'handlers': ['console'],
        'propagate': True,
    },
    #'django.db.backends': {
    #    'level': 'DEBUG',
    #},
})

# kate: space-indent on; indent-width 4;
# vim: set expandtab ts=4 sw=4:
