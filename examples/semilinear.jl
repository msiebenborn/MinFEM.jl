using MinFEM
using LinearAlgebra

function semilinear(mesh::Mesh, L::AbstractMatrix, M::AbstractMatrix,
                    s::AbstractVector, BoundaryIndices::Set{Int64}=[], tol=1e-10)

  y = zeros(mesh.nnodes)

  pde = PDESystem(A=L, b=M*s, bc=zeros(mesh.nnodes), DI=BoundaryIndices)

  res = Inf
  while res > tol
    pde.A = L + asmCubicDerivativeMatrix(mesh, y)
    pde.b = -L*y + M*s - asmCubicTerm(mesh, y)
    refresh(pde)
    solve(pde)

    y += pde.state
    res = norm(pde.state)
    println(res)
  end
  return y
end

mesh = import_mesh("../meshes/semilinear.msh")

L = asmLaplacian(mesh)
M = asmMassMatrix(mesh)

# y = 3*sin(x[1]*pi)*sin(x[2]*pi)
f(x) = 3*2*pi^2*sin(x[1]*pi)*sin(x[2]*pi) + (3*sin(x[1]*pi)*sin(x[2]*pi))^3
s = evaluateMeshFunction(mesh, f)

boundary = union(mesh.Boundaries[1001].Nodes,
                 mesh.Boundaries[1002].Nodes,
                 mesh.Boundaries[1003].Nodes,
                 mesh.Boundaries[1004].Nodes);

y = semilinear(mesh, L, M, s, boundary);

vtkfile = open_vtk_file(mesh, "semilinear.vtu")
write_point_data(vtkfile, y, "y")
write_point_data(vtkfile, s, "s")
save_vtk_file(vtkfile)
