import random

def main():
    start_num = int(input("Enter Start_num: "))
    end_num = int(input("Enter End_num: "))
    num_of_results = int(input("Num of results: "))
    random_seed_ask = input("Random seed (yes, no)? ").lower()
    allow_duplicates = input("Allow duplicates in input (yes, no)? ").lower()
    
    # set random seed so as to generate the same results if needed
    if random_seed_ask == "yes" or random_seed_ask == "y":
        random_seed = int(input("Random seed: "))
        random.seed(random_seed)
    else:
        # python does not have a true random generator, so this will make do
        random_seed = random.randint(1,9999999999) 
        random.seed(random_seed)
        pass
    
    order = input("Asc (a), Desc (d), Rand (r): ").lower()
    result_list = []
    i = 0
        
    while i <= num_of_results:       
        result = random.randint(start_num, end_num)
        result_list.append(result)
        
        # allow the user to choose whether to have duplicated results in their output
        if allow_duplicates == "yes" or allow_duplicates == "y":
            if order == "asc" or order == "a":
                result_list = list(result_list)
                result_list.sort(reverse = False)
            elif order == "desc" or order == "d":
                result_list = list(result_list)
                result_list.sort(reverse = True)
            elif order == "rand" or order == "r":
                result_list = list(result_list)
            else:
                print("Error")
        else:
        # decide the order of the results, as well as remove any duplicates
            if order == "asc" or order == "a":
                result_list = list(set(result_list))
            elif order == "desc" or order == "d":
                result_list = list(set(result_list))
                result_list.sort(reverse = True)
            elif order == "rand" or order == "r":
                result_list = list(dict.fromkeys(result_list))
            else:
                print("Error")
        
        # make sure generated list is equal to number of results defined
        if len(result_list) == num_of_results:
            print(result_list)
            print("Random seed: " + str(random_seed))
            break 
        

if __name__ == "__main__":
    main()
