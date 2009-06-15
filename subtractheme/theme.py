# Created by Keith Salisbury on 2007-07-16.
# Copyright (c) 2009 Saint Digital. All rights reserved.

from trac.core import *

from themeengine.api import ThemeBase

class SubtracTheme(ThemeBase):
    """A theme for Trac for Subtrac (http://ktec.github.com/subtrac)."""

    template = htdocs = css = screenshot = True
    
