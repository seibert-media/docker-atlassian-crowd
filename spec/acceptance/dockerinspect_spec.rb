require 'spec_helper'

describe docker_image 'atlassian-crowd:build' do 
  it { should exist }

  its(['Os']) { should eq 'linux' }
  its(['Architecture']) { should eq 'amd64' }

  its(['Author']) { should match /^\/\/SEIBERT\/MEDIA.*/ } 

  its(['Config.Cmd']) { should include '/usr/local/bin/service' }
  its(['Config.Entrypoint']) { should include '/usr/local/bin/entrypoint' }

  its(['Config.User']) { should match 'daemon' }

  its(['Config.Env']) { should include 'JAVA_VERSION_MAJOR=8' }
  its(['Config.Env']) { should include 'CROWD_INST=/opt/atlassian/crowd' }
  its(['Config.Env']) { should include 'CROWD_HOME=/var/opt/atlassian/application-data/crowd' }

  its(['Config.Volumes']) { should include '/var/opt/atlassian/application-data/crowd' }

  its(['Config.ExposedPorts']) { should include '8095/tcp' }

end
