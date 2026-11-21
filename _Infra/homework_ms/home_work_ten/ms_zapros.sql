-- диапазоны
select id, sizeid as name, portionrate as factor
from [size]
order by id;

-- склейка
select 'insert into dim_ranges(external_id, name, factor ) values ('
    + cast(id as varchar(max)) + ','''
    + [sizeid] + ''','
    + cast(portionrate as varchar(max)) + ');'
    as [sql]
from [size]

-- категории
select id, description as name,
	case when coalesce(ParentID, 0) = 0 then null else ParentID end as parent_id
from category
order by id;

-- склейка
select 'insert into dim_categories(external_id, name, parent_id ) values ('
    + cast(id as varchar(max)) + ','''
    + [description] + ''','
    + isnull(cast(nullif([ParentID], 0) as varchar(max)), 'NULL') + ');'
    as [sql]
from [category]

-- поставщики
select v.id, v.clientid as name, v.clientgroup as parent_id, g.description as parent_name
from vendors v
left join vendorgroup g on g.vendorgroupid = v.clientgroup
order by v.id;

-- склейка
select 'insert into dim_vendors(external_id, name, parent_id, parent_name ) values ('
    + cast(v.id as varchar(max)) + ','''
    + [clientid] + ''','
    + cast([clientgroup] as varchar(max)) + ','
    + '''' + isnull(g.[description], '') + ''');'
    as [sql]
from [vendors] v
left join [vendorgroup] g on g.[vendorgroupid] = v.[clientgroup]

-- товары
select id, description as name, CategoryID as category_id, vendorid as vendor_id, SizeID as range_id
from product
order by id;

-- склейка
select 'insert into dim_products(external_id, name, category_id, vendor_id, range_id ) values ('
    + cast(id as varchar(max)) + ','''
    + [description] + ''','
    + cast([CategoryID] as varchar(max)) + ','
    + cast([vendorid] as varchar(max)) + ','
    + cast([SizeID] as varchar(max)) + ');'
    as [sql]
from [product]

-- сотрудники
select personid as id, lastname, firstname, securityaccess
from personnel
order by personid;

-- склейка
select 'insert into dim_personnel(external_id, lastname, firstname, securityaccess ) values ('
    + cast(personid as varchar(max)) + ','''
    + [lastname] + ''','''
    + [firstname] + ''','
    + cast([securityaccess] as varchar(max)) + ');'
    as [sql]
from [personnel]

-- склады
select id, description as name, Address as address
from storages
order by id;

-- склейка
select 'insert into dim_storages(external_id, name, address ) values ('
    + cast(id as varchar(max)) + ','''
    + [description] + ''','''
    + isnull([Address], '') + ''');'
    as [sql]
from [storages]

-- операции
select id, Description as name, Factor as factor
from bm_StorageOperationsType
order by id;

-- склейка
select 'insert into dim_operations(external_id, name, factor ) values ('
    + cast(id as varchar(max)) + ','''
    + [Description] + ''','
    + cast([Factor] as varchar(max)) + ');'
    as [sql]
from [bm_StorageOperationsType]

-- закупка
select
	format(DateAdd, 'yyyyMM') as time_code,
	ProductID as product_id,
	VendorID as vendor_id,
	count(distinct DocumentID) as documents,
	count(*) as operations,
	sum(Count) as qty,
	sum(Amount) as amount
from bm_StorageOperations
where OperationID = 1 and VendorID <> 0
group by format(DateAdd, 'yyyyMM'), ProductID, VendorID
order by time_code, product_id, vendor_id;

-- склейка
select 'insert into fact_purchase(time_code, product_id, vendor_id, documents, operations, qty, amount ) values ('
    + format([DateAdd], 'yyyyMM') + ','
    + cast([ProductID] as varchar(max)) + ','
    + cast([VendorID] as varchar(max)) + ','
    + cast(count(distinct [DocumentID]) as varchar(max)) + ','
    + cast(count(*) as varchar(max)) + ','
    + cast(sum([Count]) as varchar(max)) + ','
    + cast(sum([Amount]) as varchar(max)) + ');'
    as [sql]
from [bm_StorageOperations]
where [OperationID] = 1 and [VendorID] <> 0
group by format([DateAdd], 'yyyyMM'), [ProductID], [VendorID]

-- продажа
select
	format(j.dater, 'yyyyMM') as time_code,
	p.id as product_id,
	count(*) as lines,
	count(distinct j.receiptn) as receipts,
	sum(j.quantity) as qty,
	sum(j.amount) as amount
from journal j
join product p on p.productid = j.id
where j.transtype = 101
group by format(j.dater, 'yyyyMM'), p.id
order by time_code, product_id;

-- склейка
select 'insert into fact_sales(time_code, product_id, lines, receipts, qty, amount ) values ('
    + format([j].[dater], 'yyyyMM') + ','
    + cast([p].[id] as varchar(max)) + ','
    + cast(count(*) as varchar(max)) + ','
    + cast(count(distinct [j].[receiptn]) as varchar(max)) + ','
    + cast(sum([j].[quantity]) as varchar(max)) + ','
    + cast(sum([j].[amount]) as varchar(max)) + ');'
    as [sql]
from [journal] j
join [product] p on p.[productid] = j.[id]
where [j].[transtype] = 101
group by format([j].[dater], 'yyyyMM'), [p].[id]

-- персонал
select
	format(DateAdd, 'yyyyMM') as time_code,
	PersonID as person_id,
	count(*) as sessions
from bm_JournalSessions
where PersonID <> 0
group by format(DateAdd, 'yyyyMM'), PersonID
order by time_code, person_id;

-- склейка
select 'insert into fact_personnel(time_code, person_id, sessions ) values ('
    + format([DateAdd], 'yyyyMM') + ','
    + cast([PersonID] as varchar(max)) + ','
    + cast(count(*) as varchar(max)) + ');'
    as [sql]
from [bm_JournalSessions]
where [PersonID] <> 0
group by format([DateAdd], 'yyyyMM'), [PersonID]

-- остатки
select
	format(DateAdd, 'yyyyMM') as time_code,
	ProductID as product_id,
	StorageID as storage_id,
	OperationID as operation_id,
	count(*) as operations,
	sum(Count) as qty,
	sum(Amount) as amount
from bm_StorageOperations
group by format(DateAdd, 'yyyyMM'), ProductID, StorageID, OperationID
order by time_code, product_id, storage_id, operation_id;

-- склейка
select 'insert into fact_inventory(time_code, product_id, storage_id, operation_id, operations, qty, amount ) values ('
    + format([DateAdd], 'yyyyMM') + ','
    + cast([ProductID] as varchar(max)) + ','
    + cast([StorageID] as varchar(max)) + ','
    + cast([OperationID] as varchar(max)) + ','
    + cast(count(*) as varchar(max)) + ','
    + cast(sum([Count]) as varchar(max)) + ','
    + cast(sum([Amount]) as varchar(max)) + ');'
    as [sql]
from [bm_StorageOperations]
group by format([DateAdd], 'yyyyMM'), [ProductID], [StorageID], [OperationID]
