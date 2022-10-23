OS_TARGET=$(strip $(firstword $(MAKECMDGOALS)))
VERSION_TARGET=$(strip $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS)))
ARCH_TARGET=$(shell uname -m | sed -e "s/68/38/" | sed -e "s/x86_64/amd64/" | sed -e "s/aarch64/arm64/")
TODAY=$(shell date -u +"%Y-%m-%d")

CONTAINER="vagrant-base-$(OS_TARGET)-$(VERSION_TARGET)-$(ARCH_TARGET)"
PACKAGE="output/${TODAY}/vagrant-lxc-$(OS_TARGET)-$(VERSION_TARGET)-$(ARCH_TARGET).box"

VALID_OS = ""
SELECTED_VERSIONS = ""

#Project Distro Support gets included here
include distro-includes

IS_FOUND := $(findstring $(VERSION_TARGET),$(SELECTED_VERSIONS))

#User has selected one of the supported linux distros for this project
$(VALID_OS):
ifneq "[]" "[${IS_FOUND}]"
	@echo $(OS_TARGET) version found! - $(VERSION_TARGET)
	@mkdir -p $$(dirname $(PACKAGE))
	@sudo -E ./mk-box.sh $(OS_TARGET) $(VERSION_TARGET) $(ARCH_TARGET) $(CONTAINER) $(PACKAGE)
	@sudo chmod +rw $(PACKAGE)
	@sudo chown ${USER}: $(PACKAGE)
else

ifeq "[]" "[$(VERSION_TARGET)]"

	@echo Please select a version for $(OS_TARGET)
	@echo Valid versions for $(OS_TARGET) are the following:
	@echo [$(strip $(SELECTED_VERSIONS))]
else
	@echo Version $(VERSION_TARGET) not a part of $(OS_TARGET)
endif

endif

#Clean up the boxes made previously
clean:
	@echo cleaning up all projects
	@sudo -E ./clean.sh "vagrant-base-[a-zA-Z]*-[a-zA-Z0-9\-\.]*-[a-zA-Z0-9]*" "output/${TODAY}/"

#Catch anything else without freaking out
%:
	@:

