module input_output
    use parameters, only : ik
    implicit none

contains

    !!Writes the heatmap to a .txt file as matrix
    subroutine write_to_file(matrix)
        implicit none
        integer (kind=ik), intent(in) :: matrix(:,:)
        integer :: i,shape_of_matrix(2)
        character(len=20) row_count

        open(unit=1,file="mandelbrot.txt",status='replace')

        !!Defining the format based on the dimensions of matrix
        shape_of_matrix = shape(matrix)
        write(row_count,*) shape_of_matrix(1)

        do i=1,shape_of_matrix(2)
            write(1,'(' // adjustl(row_count) //'I3)')matrix(:,i)
        end do

        close(1)

    end subroutine write_to_file
    
end module input_output