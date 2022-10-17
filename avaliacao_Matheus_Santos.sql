create table empresas(
	id int primary key auto_increment,
    nome varchar(45),
    cnpj varchar(18) unique not null
);

create table condutores(
	id int primary key auto_increment,
    nome varchar(45),
    nascimento date,
    carteira_de_condutor date,
    empresa_id int references empresas(id),
    ativo boolean default true
);

create table rotas(
	id int primary key auto_increment,
    nome varchar(45)
);

create table trens(
	id int primary key auto_increment,
    nome varchar(45),
    capacidade int
); 

create table viagens(
	id int primary key auto_increment,
    trem_id int references trens(id),
    partida date,
    rota_id int references rotas(id),
    condutor_id int references condutores(id)
);

create table passageiros(
	id int primary key auto_increment,
    nome varchar(45),
    nascimento date,
    cpf varchar(14) unique not null
);

create table estacoes(
	id int primary key auto_increment,
    nome varchar(45),
    cidade varchar(45),
    estado varchar(45)
);

create table rotas_estacoes(
	rota_id int references viagens(id),
    estacao_id int references estacoes(id),
    constraint primary key (rota_id, estacao_id)
);

create table passageiros_viagens(
	passageiro_id int references passageiros(id),
    viagem_id int references viagens(id),
    constraint primary key (passageiro_id,viagem_id)
    );
    
create view viagem_condutor_rota as
Select v.id as id, v.partida as partida, c.nome as condutor, r.nome as rota
	from viagens v 
	inner join condutores c
		on c.id = v.condutor_id
	inner join rotas r
		on r.id = v.rota_id
	order by v.id;
    
create view viagem_trem_passageiros as
Select v.id as id, v.partida as partida, p.nome as passageiro, p.cpf as documento
	from viagens v 
	inner join passageiros_viagens pv 
		on v.id = pv.viagem_id
	inner join passageiros p
		on p.id = pv.passageiro_id
	order by v.id;
 
 create view contratos_ativos as
 Select e.nome as empresa, c.id as codigo_condutor, c.nome as nome, timestampdiff(year,c.carteira_de_condutor,now()) as experiencia
	from empresas e
    inner join condutores c
		on c.empresa_id = e.id
	where c.ativo = true
    order by e.nome;
    
create view uso_trens as
Select t.id as id_trem, t.nome as modelo, date_format(v.partida, "%a, dia %e do mês %m do ano %Y") as data_uso
	from trens t
    inner join viagens v
		on v.trem_id = t.id
	order by t.id;
    
create view informacao_viagem as
select v.id as id_viagem, count(distinct p.id) as numero_de_passageiros, t.capacidade as lotacao, t.nome as modelo_trem, 
r.nome as rota, count(distinct es.id) as numero_estacoes, e.nome as empresa, c.nome as condutor, v.partida as partida
	from viagens v
	inner join passageiros_viagens pv
		on v.id = pv.viagem_id
	inner join passageiros p
		on p.id = pv.passageiro_id
	inner join rotas r
		on v.rota_id = r.id
	inner join rotas_estacoes re
		on re.rota_id = r.id
	inner join estacoes es
		on re.estacao_id = es.id
	inner join condutores c
		on v.condutor_id = c.id
	inner join empresas e
		on c.empresa_id = e.id
	inner join trens t
		on v.trem_id = t.id
	group by v.id
    order by v.id asc;

create view num_contratos as
Select e.nome, count(c.id) from empresas e 
	left join condutores c
		on c.empresa_id = e.id
	group by e.id
    order by e.nome asc;

delimiter $$    

create trigger tgr_inserir_empresa after insert
on empresas
for each row
begin
	if not( new.cnpj like "__.___.___/0001-__") then
		signal sqlstate '45000' set message_text = 'CNPJ Inválido';
	end if;
end $$

delimiter ;

delimiter $$    

create trigger tgr_update_empresa after update
on empresas
for each row
begin
	if not( new.cnpj like "__.___.___/0001-__") then
		signal sqlstate '45000' set message_text = 'CNPJ Inválido';
	end if;
end $$

delimiter ;

delimiter $$    

create trigger tgr_inserir_passageiro after insert
on passageiros
for each row
begin
	if not( new.cpf like "___.___.___-__") then
		signal sqlstate '45000' set message_text = 'CPF Inválido';
	end if;
end $$

delimiter ;

delimiter $$ 

create trigger tgr_update_passageiro after insert
on passageiros
for each row
begin
	if not( new.cpf like "___.___.___-__") then
		signal sqlstate '45000' set message_text = 'CPF Inválido';
	end if;
end $$

delimiter ;

insert into empresas(nome, cnpj) values ('Chaminé','00.111.111/0001-11'),
	('Sertão','01.111.111/0001-11'),
    ('Donzela de Ferro','02.111.111/0001-11'),
    ('Minhocão','03.111.111/0001-11'),
    ('Rapidão','04.111.111/0001-11'),
    ('Express','05.111.111/0001-11'),
    ('Minas','06.111.111/0001-11'),
    ('Barão','07.111.111/0001-11'),
    ('Baurú','08.111.111/0001-11'),
    ('Citadela','09.111.111/0001-11'),
    ('A deletar','10.111.111/0001-11');
    
update empresas set cnpj = '11.111.111/0001-11' where nome = 'Minas';

delete from empresas where nome = 'A deletar';

insert into condutores(nome,nascimento,carteira_de_condutor,empresa_id) values ('João','1989-05-10','2010-06-05',2),
	('Carlos','1975-08-26','2000-07-15',8),
	('Manuela','2000-01-15','2020-03-27',4),
	('Agnes','1998-05-16','2017-11-01',7),
	('Suélio','1995-01-30','2018-08-12',3),
	('Marcos','1987-06-05','2007-07-07',8),
	('Arquimedes','1996-07-01','2018-07-01',1),
	('Antonio','1991-10-15','2011-09-11',4),
	('Juarez','1993-02-27','2021-12-17',8),
	('Carmela','1975-08-31','1994-03-25',2),
	('Nicole','1978-11-03','1998-07-03',7),
	('A deletar','1980-07-09','2001-04-03',1);

update condutores set nome = 'Marco Juarez' where nome = 'Juarez';

delete from condutores where nome = 'A deletar';

insert into passageiros(nome,nascimento,cpf) values ('Contancio','2000-07-15','111.111.111-00'),
	('Marina','2000-07-15','111.111.111-01'),
	('Venancio','2000-07-15','111.111.111-02'),
	('Luis','2000-07-15','111.111.111-03'),
	('Carla','2000-07-15','111.111.111-04'),
	('José','2000-07-15','111.111.111-05'),
	('Joana','2000-07-15','111.111.111-06'),
	('Katia','2000-07-15','111.111.111-07'),
	('Marcelo','2000-07-15','111.111.111-08'),
	('Zenilde','2000-07-15','111.111.111-09'),
	('A deletar','2000-07-15','111.111.111-10');

update passageiros set nome = 'Constancio' where nome = 'Contancio';

delete from passageiros where nome = 'A deletar';        

insert into trens(nome,capacidade) values ('ModeloA',20),
	('ModeloB',35),
	('ModeloC',45),
	('ModeloD',39),
	('ModeloE',150),
	('Modelo1',238),
	('Modelo2',127),
	('Modelo3',243),
	('Modelo4',356),
	('Modelo5',78),
	('Modelo6',1);

update trens set nome = 'ModeloZ' where capacidade = 20;

delete from trens where nome = 'Modelo6';   

insert into estacoes(nome,cidade,estado) values('Central','Feira de Santana','Bahia'),
	('Mercadão','Mogi das cruzes','São Paulo'),
	('Feira de pedra','Uberlandia','Minas Gerais'),    
	('Tribuna','Juiz de Fora','Minas Gerais'),
	('Todos os Santos','Santa Luzia','Minas Gerais'),
	('Morros do Sol', 'Imperatriz','Maranhão'),
	('Peixe da Lua','Caruaru','Pernambuco'),
	('São Paulo do Norte','Paulista','Pernambuco'),
	('Areias de Ouro','Canindé','Ceará'),
	('Vila do Mar','Aracati','Ceará'),
	('MC-26','Argyre','Marte');
    
update estacoes set cidade = 'Aracoiaba' where nome = 'Vila do Mar';

delete from estacoes where nome = 'MC-26';

insert into rotas(nome) values ('Vale de ferro'),
	('Norte-Sul'),
	('Amanhecer'),
	('Anoitecer'),
	('Suleste'),
	('Deserto de Prata'),
	('Caminho do Ouro'),
	('Lagoa dos Freitas'),
	('La plata'),
	('Aveadouro'),
	('A deletar');

update rotas set nome = 'Caminho da Boiada' where nome = 'Caminho do Ouro';

delete from rotas where nome = 'A deletar'; 

delimiter $$

create procedure inicializarRota(in id_rota int,in estacao_inicial int, in estacao_final int)
begin
	if (Select count(*) from rotas where id = id_rota)=1 and (Select count(*) from estacoes where id = estacao_inicial or id = estacao_final)=2 then
		if (Select count(*) from rotas_estacoes where rota_id=id_rota) = 0 then
			insert into rotas_estacoes values (id_rota, estacao_inicial),(id_rota, estacao_final);
			select "Rota inicializada com sucesso";
		else
			select "Rota ja inicializada! Favor usar adicionarRota()";
		end if;
	else
		select "Rota ou estações inexistentes!! Favor registra - las";
	end if;
end $$

delimiter ;

delimiter $$

create procedure retirarDaRota(in id_rota int,in estacao int)
begin
	if ((Select count(distinct estacao_id) from rotas_estacoes where rota_id = id_rota)>2) 
    and ((Select rota_id from rotas_estacoes where rota_id = id_rota and estacao_id = estacao) is not null) then
		delete from rotas_estacoes where rota_id = id_rota and estacao_id = estacao;
        select "Estacao retirada com sucesso";
	else
		select "Esta Rota ou não existe ou não contem tal Estação!!";
	end if;
end $$

delimiter ;

delimiter $$

create procedure mudarRota(in id_rota int,in estacao_velha int, in estacao_nova int)
begin
	if ((Select rota_id from rotas_estacoes where rota_id = id_rota and estacao_id = estacao_velha) is not null)
    and ((Select id from rotas where id = estacao_nova) is not null) then
		update rotas_estacoes set estacao_id = estacao_nova where estacao_id = estacao_velha;
        select "Rota alterada com sucesso";
	else
		select "Rota ou estações inexistentes!! Favor registra - las";
	end if;
end $$

delimiter ;

delimiter $$

create procedure adicionarEstacao(in id_rota int,in estacao int)
begin
	if ((Select rota_id from rotas_estacoes where rota_id = id_rota and estacao_id = estacao) is null) 
    and ((Select id from rotas where id = id_rota) is not null) and ((Select id from estacoes where id = estacao) is not null) then
		insert into rotas_estacoes values (id_rota, estacao);
        select "Rota aumentada com sucesso";
	else
		select "Rota ou estações inexistentes ou Par já existente";
	end if;
end $$

delimiter ;

call inicializarRota(1,3,7);
call inicializarRota(2,7,1);
call inicializarRota(3,5,3);
call inicializarRota(4,1,5);
call inicializarRota(5,4,2);
call inicializarRota(6,6,4);
call inicializarRota(7,9,6);
call inicializarRota(8,2,8);
call inicializarRota(9,8,10);
call inicializarRota(10,10,9);

call adicionarEstacao(1,5);
call adicionarEstacao(1,4);
call adicionarEstacao(1,6);
call adicionarEstacao(2,2);
call adicionarEstacao(2,4);
call adicionarEstacao(3,4);
call adicionarEstacao(7,1);
call adicionarEstacao(7,3);
call adicionarEstacao(7,5);
call adicionarEstacao(7,2);
call adicionarEstacao(9,7);

call retirarDaRota(9,7);

call mudarRota(9,8,7);

delimiter $$

create procedure criarViagem(in trem int, in data_partida date, in rota int,in condutor int)
begin
	if not( ((Select id from trens where id = trem) is null) or ((Select id from rotas where id = rota) is null) or ((Select id from condutores where id = condutor) is null) or (timestampdiff(second,now(),data_partida)<0)) then
		if(Select id from viagens where trem_id = trem and data_partida = partida and rota_id = rota and condutor_id = condutor) is null then
			insert into viagens(trem_id, partida, rota_id, condutor_id) values (trem, data_partida, rota, condutor);
			select "Viagem adicionada com sucesso";
		else
			select "Viagem já existente";
		end if;
	else
		select "Um dos registros não é válido";
	end if;
end $$

delimiter ;

delimiter $$

create procedure mudarViagem(in id_viagem int, in trem int, in data_partida date, in rota int,in condutor int)
begin
	if not( ((Select id from trens where id = trem) is null) or ((Select id from rotas where id = rota) is null) or ((Select id from condutores where id = condutor) is null) or timestampdiff(second,now(),data_partida)<0) then
		if ((Select id from viagens where trem_id = trem and data_partida = partida and rota_id = rota and condutor_id = condutor and id <> id_viagem) is null) and
        ((Select id from viagens where id = id_viagem) is not null)then
			update viagens set trem_id = trem, partida = data_partida, rota_id = rota, condutor_id = condutor where id = id_viagem;
			select "Viagem alterada com sucesso";
		else
			select "Viagem inexistente ou duplicada";
		end if;
	else
		select "Um dos registros não é válido";
	end if;
end $$

delimiter ;

delimiter $$

create procedure deletarViagem(in id_viagem int)
begin
	if (Select id from viagens where id = id_viagem) is not null then
		if ((select count(*) from passageiros_viagens where viagem_id = id_viagem)=0)then
			delete from viagens where id = id_viagem;
			select "Viagem deletada 
            com sucesso";
		else
			select "Passageiros registrados nessa viagem, favor exlui-los";
		end if;
	else
		select "Viagem inexistente";
	end if;
end $$

delimiter ;

call criarViagem(1,'2022-12-01',2,9);
call criarViagem(2,'2022-12-02',4,7);
call criarViagem(3,'2022-12-03',6,6);
call criarViagem(4,'2022-12-04',8,8);
call criarViagem(5,'2022-12-05',10,4);
call criarViagem(6,'2022-12-06',1,5);
call criarViagem(6,'2022-12-06',5,2);
call criarViagem(6,'2022-12-07',3,1);
call criarViagem(6,'2022-12-08',7,8);
call criarViagem(8,'2022-12-09',9,3);
call criarViagem(8,'2022-12-09',4,10);
call criarViagem(8,'2022-12-06',7,10);

call mudarViagem(12,9,'2022-12-06',7,10);

call deletarViagem(12);

delimiter $$

create procedure adicionarPassageiro(in viagem int, in passageiro int)
begin
	if((select id from viagens where id = viagem) is not null) and ((select id from passageiros where id = passageiro) is not null) and ((select passageiro_id from passageiros_viagens where passageiro_id = passageiro and viagem_id = viagem) is null)then
		if (select t.capacidade from trens t inner join viagens v on v.trem_id = t.id where v.id = viagem) >= (select count(*) from passageiros_viagens where viagem_id = viagem) then
			insert into passageiros_viagens values (passageiro,viagem);
            select "Passageiro Adicionado";
		else
			select "Trem lotado";
		end if;
	else
		select "Dados inválidos";
	end if;
end $$

delimiter ;

delimiter $$

create procedure mudarPassageiro(in viagem_old int, in passageiro_old int, in viagem_new int, in passageiro_new int)
begin
	if((select id from viagens where id = viagem_new) is not null) and ((select id from passageiros where id = passageiro_new) is not null) and (((select passageiro_id from passageiros_viagens where passageiro_id = passageiro_new and viagem_id = viagem_new) is null) and ((select viagem_id from passageiros_viagens where passageiro_id = passageiro_old and viagem_id = viagem_old)is not null) )then
		if (select t.capacidade from trens t inner join viagens v on v.trem_id = t.id where v.id = viagem_new) >= (select count(*) from passageiros_viagens where viagem_id = viagem_new) then
			update passageiros_viagens set passageiro_id = passageiro_new, viagem_id = viagem_new where passageiro_id = passageiro_old and viagem_id = viagem_old;
            select "Passagem Alterada";
		else
			select "Trem lotado";
		end if;
	else
		select "Dados inválidos";
	end if;
end $$

delimiter ;

delimiter $$

create procedure retirarPassageiro(in viagem int, in passageiro int)
begin
	if(Select viagem_id from passageiros_viagens where passageiro_id = passageiro and viagem_id = viagem) is not null then
		delete from passageiros_viagens where passageiro_id = passageiro and viagem_id = viagem;
        select "Passageiro Retirado";
	else
		select "Passageiro não registrado";
	end if;
end $$

delimiter ;

call adicionarPassageiro(1,1);
call adicionarPassageiro(2,2);
call adicionarPassageiro(3,3);
call adicionarPassageiro(4,4);
call adicionarPassageiro(5,5);
call adicionarPassageiro(6,6);
call adicionarPassageiro(7,7);
call adicionarPassageiro(8,8);
call adicionarPassageiro(9,9);
call adicionarPassageiro(10,10);
call adicionarPassageiro(11,1);
call adicionarPassageiro(11,2);
call adicionarPassageiro(11,3);
call adicionarPassageiro(11,4);

call mudarPassageiro(11,4,10,4);

call retirarPassageiro(10,4);
