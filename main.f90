program main
    use parameters
    use mandelbrot, only : generate_heat_map
    use input_output, only : write_to_file
    implicit none
    integer (kind=ik),dimension(:,:),allocatable :: heat_map_matrix

    call generate_heat_map(heat_map_matrix)
    call write_to_file(heat_map_matrix)

end program main