! RUN: %python %S/../test_errors.py %s %flang -fopenacc

! Check OpenACC clause validity for the following construct and directive:
!   2.9 Loop

program openacc_loop_validity

  implicit none

  type atype
    real(8), dimension(10) :: arr
    real(8) :: s
  end type atype

  integer :: i, j, b, gang_size, vector_size, worker_size
  integer, parameter :: N = 256
  integer, dimension(N) :: c
  logical, dimension(N) :: d, e
  integer :: async1
  integer :: wait1, wait2
  real :: reduction_r
  logical :: reduction_l
  real(8), dimension(N, N) :: aa, bb, cc
  logical :: ifCondition = .TRUE.
  type(atype) :: t
  type(atype), dimension(10) :: ta

  real(8), dimension(N) :: a, f, g, h

  !$acc parallel
  !$acc loop tile(2)
  do i = 1, N
    a(i) = 3.14
  end do
  !$acc end parallel

  !$acc parallel device_type(*) num_gangs(2)
  !$acc loop
  do i = 1, N
    a(i) = 3.14
  end do
  !$acc end parallel

  !$acc parallel
  !$acc loop seq
  do i = 1, N
    a(i) = 3.14
  end do
  !$acc end parallel

  !$acc parallel
  !$acc loop independent
  do i = 1, N
    a(i) = 3.14
  end do
  !$acc end parallel

  !$acc parallel
  !$acc loop auto
  do i = 1, N
    a(i) = 3.14
  end do
  !$acc end parallel

  !$acc parallel
  !ERROR: At most one VECTOR clause can appear on the LOOP directive or in group separated by the DEVICE_TYPE clause
  !$acc loop vector vector(128)
  do i = 1, N
    a(i) = 3.14
  end do
  !$acc end parallel

  !$acc parallel
  !$acc loop vector
  do i = 1, N
    a(i) = 3.14
  end do
  !$acc end parallel

  !$acc parallel
  !$acc loop vector(10)
  do i = 1, N
    a(i) = 3.14
  end do
  !$acc end parallel

  !$acc parallel
  !$acc loop vector(vector_size)
  do i = 1, N
    a(i) = 3.14
  end do
  !$acc end parallel

  !$acc parallel
  !$acc loop vector(length: vector_size)
  do i = 1, N
    a(i) = 3.14
  end do
  !$acc end parallel

  !$acc parallel
  !ERROR: At most one WORKER clause can appear on the LOOP directive or in group separated by the DEVICE_TYPE clause
  !$acc loop worker worker(10)
  do i = 1, N
    a(i) = 3.14
  end do
  !$acc end parallel

  !$acc parallel
  !$acc loop worker
  do i = 1, N
    a(i) = 3.14
  end do
  !$acc end parallel

  !$acc parallel
  !$acc loop worker(10)
  do i = 1, N
    a(i) = 3.14
  end do
  !$acc end parallel

  !$acc parallel
  !$acc loop worker(worker_size)
  do i = 1, N
    a(i) = 3.14
  end do
  !$acc end parallel

  !$acc parallel
  !$acc loop worker(num: worker_size)
  do i = 1, N
    a(i) = 3.14
  end do
  !$acc end parallel

  !$acc parallel
  !ERROR: At most one GANG clause can appear on the LOOP directive or in group separated by the DEVICE_TYPE clause
  !$acc loop gang gang(gang_size)
  do i = 1, N
    a(i) = 3.14
  end do
  !$acc end parallel

  !$acc loop gang device_type(default) gang(gang_size)
  do i = 1, N
    a(i) = 3.14
  end do

  !ERROR: At most one GANG clause can appear on the PARALLEL LOOP directive or in group separated by the DEVICE_TYPE clause
  !$acc parallel loop gang gang(gang_size)
  do i = 1, N
    a(i) = 3.14
  end do

  !$acc parallel loop gang device_type(default) gang(gang_size)
  do i = 1, N
    a(i) = 3.14
  end do

  !$acc parallel
  !$acc loop gang(gang_size)
  do i = 1, N
    a(i) = 3.14
  end do
  !$acc end parallel

  !$acc parallel
  !$acc loop gang(num: gang_size)
  do i = 1, N
    a(i) = 3.14
  end do
  !$acc end parallel

  !$acc parallel
  !$acc loop gang(gang_size, static:*)
  do i = 1, N
    a(i) = 3.14
  end do
  !$acc end parallel

  !$acc parallel
  !$acc loop gang(num: gang_size, static:*)
  do i = 1, N
    a(i) = 3.14
  end do
  !$acc end parallel

  !$acc parallel
  !$acc loop gang(num: gang_size, static: gang_size)
  do i = 1, N
    a(i) = 3.14
  end do
  !$acc end parallel

  !$acc parallel
  !$acc loop private(b, a(:))
  do i = 1, N
    a(i) = b
  end do
  !$acc end parallel

  !$acc parallel
  !$acc loop tile(*)
  do i = 1, N
    a(i) = b
  end do
  !$acc end parallel

  !$acc parallel
  !$acc loop tile(2, 2)
  do i = 1, N
    do j = 1, N
      a(i) = b
    end do
  end do
  !$acc end parallel

  !$acc parallel
  !ERROR: The parameter of the COLLAPSE clause must be a constant positive integer expression
  !$acc loop collapse(-1)
  do i = 1, N
    do j = 1, N
      a(i) = 3.14 + j
    end do
  end do
  !$acc end parallel

  !$acc parallel
  !ERROR: Clause PRIVATE is not allowed after clause DEVICE_TYPE on the LOOP directive
  !$acc loop device_type(*) private(i)
  do i = 1, N
    a(i) = 3.14
  end do
  !$acc end parallel

  !$acc parallel
  !ERROR: Clause GANG is not allowed if clause SEQ appears on the LOOP directive
  !$acc loop gang seq
  do i = 1, N
    a(i) = 3.14
  end do
  !$acc end parallel

  !$acc parallel
  !ERROR: Clause WORKER is not allowed if clause SEQ appears on the LOOP directive
  !$acc loop worker seq
  do i = 1, N
    a(i) = 3.14
  end do
  !$acc end parallel

  !$acc parallel
  !ERROR: Clause VECTOR is not allowed if clause SEQ appears on the LOOP directive
  !$acc loop vector seq
  do i = 1, N
    a(i) = 3.14
  end do
  !$acc end parallel

  !ERROR: Clause IF is not allowed after clause DEVICE_TYPE on the PARALLEL directive
  !$acc parallel device_type(*) if(.TRUE.)
  !$acc loop
  do i = 1, N
    a(i) = 3.14
  end do
  !$acc end parallel

  !$acc loop collapse(2)
  do i = 1, N
    !ERROR: Loop control is not present in the DO LOOP
    do
      a(i) = 3.14
    end do
  end do

  !ERROR: The num argument is not allowed when dim is specified
  !$acc loop gang(1, dim: 2)
  do i = 1, N
  end do

  !$acc loop
  do i = 1, N
  end do
  !$acc end loop

  !$acc loop collapse(2)
  do i = 1, 10
    !ERROR: LOOP directive not expected in COLLAPSE loop nest
    !$acc loop
    do j = 1, 10
    end do
  end do

  !$acc parallel
  !$acc loop
  do i = 1, n
    if(i == 10) cycle
  end do
  !$acc end parallel

  !$acc loop gang device_type(nvidia) gang(num: 8)
  DO i = 1, n
  END DO

  !$acc loop vector device_type(default) vector(16)
  DO i = 1, n
  END DO

  !$acc loop worker device_type(*) worker(8)
  DO i = 1, n
  END DO

  !$acc loop device_type(multicore) collapse(2)
  DO i = 1, n
    DO j = 1, n
    END DO
  END DO

end program openacc_loop_validity
