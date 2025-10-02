program uranium

    use version_module
    use interpret_module

    integer :: argument
    integer :: return_interpret

    character(len=32) :: command

    character(len=32) :: vers

    argument = 1

    call get_command_argument(argument, command)
    
    if (command == "--version") then
        vers = version()
        print *, vers

    else if (command == "-V") then
        vers = version()
        print *, vers

    else
        return_interpret = interpret(command)

    end if

end program