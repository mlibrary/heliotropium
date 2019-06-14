# -*- coding: utf-8 -*-

import guzzle_sphinx_theme

# -- Project information -----------------------------------------------------

project = u'Chipmunk'
copyright = u'2019, Regents of the University of Michigan'
author = u'University of Michigan'
version = u''
release = u''

# -- General configuration ---------------------------------------------------

extensions = [
    'guzzle_sphinx_theme',
    'sphinx.ext.coverage',
    'sphinxcontrib.plantuml',
    'sphinxcontrib.httpdomain'
]

templates_path = ['_templates']
source_suffix = ['.rst']
master_doc = 'index'
language = None
pygments_style = 'sphinx'

exclude_patterns = [
    '_build',
    'Thumbs.db',
    '.DS_Store',
    '_yard'
]

todo_include_todos = False

# -- Options for HTML output -------------------------------------------------

html_theme_path = guzzle_sphinx_theme.html_theme_path()
html_theme = 'guzzle_sphinx_theme'
html_static_path = ['_static']

html_theme_options = {
    "project_nav_name": project,
}

html_sidebars = {
    '**': [
        'logo-text.html',
        'globaltoc.html',
        'searchbox.html',
    ]
}

# -- httpdomain options

http_index_shortname = 'api'
http_index_localname = 'Chipmunk API'
http_strict_mode = True
