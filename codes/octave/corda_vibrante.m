## Corda vibrante 1D (EDO/EDP) – autovalores e autovetores
## Gera saída em pasta própria dentro de codigos/octave e salva figuras/dados.

function corda_vibrante()
  clc;
  printf("Corda vibrante – PIN: autovalores/autovetores\n");

  % ---------- Configuração de renderização (headless friendly) ----------
  try
    graphics_toolkit ("qt");
  catch
    graphics_toolkit ("gnuplot");
  end
  set(0, "defaultfigurevisible", "off");  % evita abrir janelas no servidor

  % ---------- Parâmetros físicos e numéricos ----------
  L = 1.0;          % comprimento [m]
  T = 10.0;         % tensão [N]
  rho = 0.01;       % densidade linear [kg/m]
  c = sqrt(T/rho);  % velocidade de ondas [m/s]

  N = 200;          % pontos espaciais (malha FD)
  x = linspace(0, L, N)';
  dx = x(2)-x(1);

  Mmax = 5;         % quantos modos salvar
  tmax = 2.0;       % tempo para animação (s)
  nt = 60;          % frames

  % ---------- Solução analítica dos autovalores ----------
  % Modos: phi_m(x) = sin(m*pi*x/L), omegas: w_m = m*pi*c/L
  m = (1:Mmax)';
  w = m * pi * c / L;       % frequências angulares
  f = w/(2*pi);             % frequências [Hz]

  % ---------- Método numérico (diferenças finitas) para -d2/dx2 ----------
  e = ones(N,1);
  D2 = spdiags([e -2*e e], [-1 0 1], N, N)/(dx^2);
  % Condições de contorno fixas: u(0)=u(L)=0
  D2(1,:) = 0; D2(1,1) = 1;         % impõe u(1)=0
  D2(N,:) = 0; D2(N,N) = 1;         % impõe u(N)=0
  % Resolver autovalores do operador espacial interno (2..N-1)
  [Vnum, Lam] = eig(full(D2(2:N-1, 2:N-1)));
  lam = diag(Lam);  % autovalores espaciais
  [lam_sorted, idx] = sort(lam); Vnum = Vnum(:, idx);

  % Frequências numéricas aproximadas:
  w_num = sqrt(-lam_sorted) * c;        % w = c*sqrt(k^2); lam ~ -k^2
  f_num = w_num/(2*pi);

  % ---------- Criar pasta de saída ----------
  ts = strftime("%Y%m%d-%H%M%S", localtime(time()));
  out_name = sprintf("vibrating_string_L%.2f_T%.2f_rho%.3f_modes%d", L, T, rho, Mmax);
  out_dir = fullfile(pwd, out_name);
  if exist(out_dir, "dir")
    out_dir = [out_dir "_" ts];
  end
  mkdir(out_dir);

  % ---------- Salvar espectro (analítico x numérico) ----------
  fig1 = figure(1); clf;
  plot(m, f, "o-", "linewidth", 1.5); hold on;
  plot(1:length(f_num(1:Mmax)), f_num(1:Mmax), "s-", "linewidth", 1.5);
  grid on; xlabel("modo m"); ylabel("frequência [Hz]");
  legend("analítico", "numérico", "location", "northwest");
  title("Corda vibrante: frequências dos modos");
  print(fig1, fullfile(out_dir, "frequencias_modos.png"), "-dpng", "-r200");

  % ---------- Salvar formas modais analíticas ----------
  fig2 = figure(2); clf;
  cm = lines(Mmax);
  for k=1:Mmax
    phi = sin(k*pi*x/L);
    plot(x, phi, "linewidth", 1.5); hold on;
  end
  grid on; xlabel("x [m]"); ylabel("\phi_m(x)");
  title("Corda vibrante: formas modais analíticas");
  print(fig2, fullfile(out_dir, "modos_analiticos.png"), "-dpng", "-r200");

  % ---------- Animação simples (combinação de modos) ----------
  % u(x,t) = sum_{m=1..Mmax} A_m sin(m*pi*x/L) cos(w_m t)
  A = exp(-0.3*(0:Mmax-1)');  % amplitudes decrescentes
  tt = linspace(0, tmax, nt);
  fig3 = figure(3); clf;
  for it=1:length(tt)
    t = tt(it);
    u = zeros(size(x));
    for k=1:Mmax
      u += A(k) * sin(k*pi*x/L) * cos(w(k)*t);
    end
    plot(x, u, "linewidth", 2);
    axis([0 L -1.2 1.2]); grid on;
    xlabel("x [m]"); ylabel("u(x,t)"); title(sprintf("t = %.3f s", t));
    drawnow;
    print(fig3, fullfile(out_dir, sprintf("frame_%03d.png", it)), "-dpng", "-r150");
  end

  % ---------- Salvar dados ----------
  save(fullfile(out_dir, "params.mat"), "L","T","rho","c","Mmax","tmax","nt");
  save(fullfile(out_dir, "frequencias_analiticas.txt"), "f", "-ascii");
  save(fullfile(out_dir, "frequencias_numericas.txt"), "f_num", "-ascii");
  dlmwrite(fullfile(out_dir, "x_grid.txt"), x, "delimiter", "\t");

  printf("✅ Concluído. Saída em: %s\n", out_dir);
end

% Executa quando rodar: octave -qf corda_vibrante.m
corda_vibrante();
