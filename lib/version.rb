# -*- coding: UTF-8 -*-
#
# Copyright 2013 whiteleaf. All rights reserved.
#

Version = "1.0.1"

cv_path = File.expand_path(File.join(File.dirname(__FILE__), "../commitversion"))
CommitVersion = File.read(cv_path)
