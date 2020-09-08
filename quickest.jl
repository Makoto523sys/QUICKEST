using Plots;
using Printf;
gr();
anim = Animation();
f(x) = 1/2*cos(8pi*(x-1/2));

function forward(u_old::Array, i::Int64)
	return -(2u_old[ir[i] + 3u_old[i] - 6u_old[il[i]] + u_old[il2[i]])C / 6 + (u_old[ir[i]] - 2u_old[i] + u_old[il[i]])C^2 / 2 - (u_old[ir[i]] - 3u_old[i] + 3u_old[il[i]] - u_old[il2[i]])C^3 / 6;
end

function backward(u_old::Array, i::Int64)
	return (2u_old[il[i] + 3u_old[i] - 6u_old[ir[i]] + u_old[ir2[i]])C / 6 + (u_old[il[i]] - 2u_old[i] + u_old[ir[i]])C^2 / 2 + (u_old[il[i]] - 3u_old[i] + 3u_old[ir[i]] - u_old[ir2[i]])C^3 / 6;
end

function main()
#=********Numerical Set Up*********=#
	global c = 1.0;
	global nx = 101;
	global lx = 100;
	global x = range(0.0, stop=lx, length=nx);
	global dx = lx /(nx-1);
	global u  = zeros(Float64, nx);
	@inbounds for i = 1:nx
		if 40.0 < x[i] < 60.0; 
			u[i] = f(x[i]);
		end
	end
	global t = 0.0;
	global dt = 5e-1;
	global tlims = 300;
	global C = dt * c / dx;
	global ir = zeros(Int64, nx);
	global ir2 = zeros(Int64, nx);
	global il = zeros(Int64, nx);
	global il2 = zeros(Int64, nx);
	@inbounds for i = 1:nx
		ir[i] = i + 1;
		ir2[i] = i + 2;
		il[i] = i - 1;
		il2[i] = i - 2;
	end
	ir[end] = 1;
	ir2[end - 1] = 1;
	ir2[end] = 2;
	il[begin] = nx;
	il2[begin + 1] = nx;
	il2[begin] = nx - 1;
#=******Finish Numerical Set Up*************=#

	while t < tlims
		u_old = copy(u);
		@inbounds for i = 1:nx-1
			u[i] = u_old[i] + forward(u_old, i);
		end
		u[begin] = u[end];

		plt = plot(x, u, xlims=(0, lx), xticks=0:lx/5:lx, ylims=(-0.2, 1.2), yticks=-0.2:0.2:1.2,
		xlabel="x", ylabel="u", color="blue", title="QUICKEST", label=@sprintf("t=%.1f", t));
		frame(anim, plt);
		t += dt;
		@printf("t = %.4f\n", t);
	end
	gif(anim, "quickest.gif", fps=5);
end

main();
