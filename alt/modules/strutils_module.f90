module strutils_module

    implicit none

    contains
        function replace(string, substring, new)
            character(len=*) :: string, substring, new
            character(len=256) :: part_one

            character(len=256) :: replace

            part_one = trim(string(index(string, substring)+len(substring):len(trim(string))))
            replace = trim(string(1:index(string, substring)-1)) // new // trim(part_one)

        end function replace

        function startsWith(string, substring)
            character(len=*) :: string, substring
            integer :: startsWith

            if (index(string, substring) == 1) then
                startsWith = 1
            else
                startsWith = 0
            end if
        end function startsWith

end module strutils_module