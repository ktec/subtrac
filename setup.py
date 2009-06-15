#!/usr/bin/env python
# -*- coding: iso-8859-1 -*-

from setuptools import setup

setup(
    name = 'TracSubtracTheme',
    version = '1.0',
    packages = ['subtractheme'],
    package_data = { 'subtractheme': ['templates/*.html', 'htdocs/*.css', 'htdocs/img/*.gif', 'htdocs/img/*.jpg', 'htdocs/img/*.png' ] },

    author = 'Keith Salisbury',
    author_email = 'keithsalisbury@gmail.com',
    description = 'A theme for Trac.',
    license = 'BSD',
    keywords = 'trac plugin theme',
    url = 'http://ktec.github.com/subtrac/subtractheme',
    classifiers = [
        'Framework :: Trac',
    ],
    
    install_requires = ['Trac', 'TracThemeEngine>=2.0'],

    entry_points = {
        'trac.plugins': [
            'subtractheme.theme = subtractheme.theme',
        ]
    },
)
