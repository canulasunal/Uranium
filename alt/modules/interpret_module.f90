module interpret_module
    use strutils_module

    implicit none

contains
    function interpret(filename)
        character(len=32) :: filename

        integer :: file_confirm
        integer :: file_unit_number
        integer :: interpret
        integer :: x

        character(len=256) :: line

        open(unit=file_unit_number, file=trim(filename), status="old", action="read", iostat=file_confirm)

        if (file_confirm /= 0) then
            print *, "E: File does not exist."
            stop
        end if

        do
            read(file_unit_number, "(A)", iostat=file_confirm) line
            if (file_confirm /= 0) exit
            line = trim(line)

            if (index(string=line, substring="println(") /= 0) then
                line = trim(line(9:len(trim(line))-1))
                do x = 0, 2
                    line = replace(line, """", "")
                end do
                write(6, "(A)") trim(line)
            end if
        end do

        interpret = 0
    end function interpret

end module interpret_module