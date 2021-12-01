module mandelbrot
    use parameters
    implicit none  
    real(kind=rk), parameter :: step=1.0_rk/n
    
contains

    subroutine generate_heat_map(matrix)

        implicit none
        integer (kind=ik),allocatable,intent(inout) :: matrix(:,:)
        integer (kind=ik) :: count,max_iteration=50
        integer :: i,j
        complex (kind=rk) :: z,z_0
        
        !!abs_x*n+1 and abs_y*n+1 since the plot has a aspect ratio of 2:3
        allocate(matrix(abs_x*n+1,abs_y*n+1))

        do i=0,abs_x*n
            do j=0,abs_y*n              
                count=0                                                         
                z = 0                                                          
                z_0 = complex(step*i*1.0+lower_x,(step*j*1.0+lower_y)*(-1))
                
                !!Mandelbrot set conditions. Calculates if c converges or diverges
                do while (abs(z) < 2 .and. count < max_iteration)
                    z = z*z + z_0
                    count = count + 1_ik
                end do

                matrix(i+1,j+1) = count
            end do
        end do

    end subroutine generate_heat_map

end module mandelbrot