module version_module
    implicit none

contains
    function version()
        character(len=32) :: version
        version = "Uranium Language 0.4.1"
    end function version

end module version_module