from .settings import *

# Database is now local
DATABASES = {
    'default': {
                'ENGINE': 'django.db.backends.postgresql',
                'NAME': 'postgres',
                'USER': 'postgres',
                'HOST': 'localhost',
                'PORT': 5432,
            },
}
