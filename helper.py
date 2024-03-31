import pandas as pd

def txt_data_path(year):
	return f'data\\raw\\yob{year}.txt'

def count(start_year=1880, end_year=2022):
	"""
	Count the number of entries in the available data within
	a specific period of time.
		- There are 2,085,158 instances at total between 1880 and 2022.
		- 722,322 in 2001-2022 period (21st century).
		- 416,257 in 1901-1950.
		- 890,586 in 1951-2000.
	"""
	total = 0
	for year in range(start_year, end_year+1):
		with open(txt_data_path(year)) as file:
			total += len(file.readlines())
	return total

def assemble(start_year=1880, end_year=2022):
	"""
	Put all entries from all text files into a single CSV, adding a header
	with an extra column for the year of record.
	"""
	csv_file = open('data\\names.csv', 'w')
	csv_file.write("name,gender,occurences,year\n")
	for year in range(start_year, end_year+1):
		with open(txt_data_path(year)) as file:
			for line in file:
				csv_file.write(f"{line[:-1]},{year}\n")
	csv_file.close()
	return

def drop_abs_rarest(low_bound=1000):
	"""
	Creates an alternative dataset containing only the names above
	an absolute minimum.
	The resulting file exhibits 55,798 entries for low_bound=1000
	and 104,435 for low_bound=400.
	"""
	cn_csv = open('data\\abs_common_names.csv', 'w')
	cn_csv.write("name,gender,occurences,year\n")
	with open("data\\names.csv") as file:
		file.readline()
		for line in file:
			occurences = int(line.split(',')[2])
			if occurences >= low_bound:
				cn_csv.write(line)
	cn_csv.close()
	return

def drop_rel_rarest(up_rate=0.2):
	"""
	Similar to the other one, but the lower bound is relative rather
	than absolute. If up_rate=0.20, then only the top 20% most frequent
	names of each year will be preserved.
	For up_rate=0.05, the resulting CSV has 104,189 entries.
	"""
	names_data = pd.read_csv("data\\names.csv")
	output_data = pd.DataFrame()
	for year in range(1880, 2023):
		target_names = names_data[names_data['year'] == year]
		target_names = target_names.sort_values(by=['occurences'], ascending=False)
		target_names = target_names.head(int(len(target_names) * up_rate))
		output_data = pd.concat([output_data, target_names])
	output_data.to_csv("data\\rel_common_names.csv", index=False)
	return

# Main

if __name__ == '__main__':
	assemble()
	drop_abs_rarest(low_bound=400)
	drop_rel_rarest(up_rate=0.05)












