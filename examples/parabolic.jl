using MinFEM
using WriteVTK

function parabolic(;theta=1.0)
  mesh = unit_square(100)

  boundary = union(mesh.Boundaries[1001].Nodes,
                   mesh.Boundaries[1002].Nodes,
                   mesh.Boundaries[1003].Nodes,
                   mesh.Boundaries[1004].Nodes)

  L = asmLaplacian(mesh)
  M = asmMassMatrix(mesh)

  tsteps = 10
  T = 1.0
  dt = (T-0)/tsteps

  source(x) = 1.0
  f = evaluateMeshFunction(mesh, source)

  initial_condition(x) = 0.0
  u = evaluateMeshFunction(mesh, initial_condition)

  for i=1:tsteps

    if i==1
      vtkfile = write_vtk_mesh(mesh, "parabolic_"*lpad(string(0), 3, '0')*".vtu")
      vtk_point_data(vtkfile, u, "u")
      vtk_save(vtkfile)
    end

    #M*(u_new - u)/dt + L(theta*u_new + (1.0-theta)*u) = M*f
    pde = PDESystem(A=(M + theta*dt*L), b=(M*(f+u) - (1.0-theta)*dt*L*u), bc=zeros(mesh.nnodes), DI=boundary)
    solve(pde)

    u = copy(pde.state)

    vtkfile = write_vtk_mesh(mesh, "parabolic_"*lpad(string(i), 3, '0')*".vtu")
    vtk_point_data(vtkfile, u, "u")
    vtk_save(vtkfile)
  end

end
parabolic(theta=0.5)

