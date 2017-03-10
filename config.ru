# frozen_string_literal: true
require './init.rb'
require 'faye'

use Faye::RackAdapter, mount: '/events', timeout: 25
run BlameMe
