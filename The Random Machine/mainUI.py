import random
import tkinter as tk
from tkinter import ttk, messagebox

def generate_list():
    try:
        start_num = int(start_num_entry.get())
        end_num = int(end_num_entry.get())
        num_of_results = int(num_of_results_entry.get())
        random_seed_ask = random_seed_ask_var.get().lower()
        allow_duplicates= allow_duplicates_var.get().lower()
        
        # Set random seed to generate consistent results if needed
        if random_seed_ask == "y":
            random_seed = int(random_seed_entry.get())
            random.seed(random_seed)
        elif random_seed_ask == "n":
            # Python does not have a true random generator, so this will make do
            random_seed = random.randint(1, 9999999999) 
            random.seed(random_seed)
        else:
            messagebox.showerror("Error", "Please select random seed option.")
            return
        
        order = order_var.get().lower()
        result_list = []
        i = 0
        
        while i < num_of_results:
            result = random.randint(start_num, end_num)
            result_list.append(result)
            i += 1
        
         # allow the user to choose whether to have duplicated results in their output
        if allow_duplicates == "y":
            match order:
                case "a":
                    result_list = list(result_list)
                    result_list.sort(reverse = False)
                case "d":
                    result_list = list(result_list)
                    result_list.sort(reverse = True)
                case "r":
                    result_list = list(result_list)
                case _:
                    messagebox.showerror("Error", "Invalid order selection")
                    return
        elif allow_duplicates == "n":
        # decide the order of the results, as well as remove any duplicates
            match order:
                case "a": 
                    result_list = list(set(result_list))
                case "d":
                    result_list = list(set(result_list))
                    result_list.sort(reverse = True)
                case "r":
                    result_list = list(dict.fromkeys(result_list))
                case _:
                    messagebox.showerror("Error", "Invalid order selection")
                    return
        else:
            messagebox.showerror("Error", "Please select duplicate option.")
            return
        
        # Display the generated list
        if len(result_list) == num_of_results:
            result_list_str = ', '.join(map(str, result_list))
            results_entry.delete(0, tk.END)
            results_entry.insert(0, result_list_str)
            seed_entry.delete(0, tk.END)
            seed_entry.insert(0, str(random_seed))


    except ValueError as ve:
        messagebox.showerror("Input Error", str(ve))

# Create the main window
root = tk.Tk()
root.iconbitmap("Aniket-Suvarna-Box-Regular-Bx-shuffle.ico")
root.title("Random Number Generator")

# Input fields and labels
start_num_label = tk.Label(root, text="Start Number:")
start_num_label.grid(row=0, column=0, padx=5, pady=5)
start_num_entry = tk.Entry(root)
start_num_entry.grid(row=0, column=1, padx=5, pady=5)

end_num_label = tk.Label(root, text="End Number:")
end_num_label.grid(row=1, column=0, padx=5, pady=5)
end_num_entry = tk.Entry(root)
end_num_entry.grid(row=1, column=1, padx=5, pady=5)

num_of_results_label = tk.Label(root, text="Number of Results:")
num_of_results_label.grid(row=2, column=0, padx=5, pady=5)
num_of_results_entry = tk.Entry(root)
num_of_results_entry.grid(row=2, column=1, padx=5, pady=5)

random_seed_ask_label = tk.Label(root, text="Random Seed (y/n):")
random_seed_ask_label.grid(row=3, column=0, padx=5, pady=5)
random_seed_ask_var = tk.StringVar()
random_seed_ask_entry = tk.Entry(root, textvariable=random_seed_ask_var)
random_seed_ask_entry.grid(row=3, column=1, padx=5, pady=5)

random_seed_label = tk.Label(root, text="Random Seed:")
random_seed_label.grid(row=4, column=0, padx=5, pady=5)
random_seed_entry = tk.Entry(root)
random_seed_entry.grid(row=4, column=1, padx=5, pady=5)

allow_duplicates_label = tk.Label(root, text="Allow Duplicates (y/n):")
allow_duplicates_label.grid(row=5, column=0, padx=5, pady=5)
allow_duplicates_var = tk.StringVar()
allow_duplicates_entry = tk.Entry(root, textvariable=allow_duplicates_var)
allow_duplicates_entry.grid(row=5, column=1, padx=5, pady=5)

order_label = tk.Label(root, text="Order Asc, Desc, Rand (a, d, r):")
order_label.grid(row=6, column=0, padx=5, pady=5)
order_var = tk.StringVar()
order_entry = tk.Entry(root, textvariable=order_var)
order_entry.grid(row=6, column=1, padx=5, pady=5)

# Generate button
generate_button = tk.Button(root, text="Generate", command=generate_list)
generate_button.grid(row=7, column=0, columnspan=2, pady=10)

# Results display
seed_label = tk.Label(root, text="Random seed: ")
seed_label.grid(row=9, column=0, padx=5, pady=5)
seed_entry = tk.Entry(root, state='normal')
seed_entry.grid(row=9, column=1, padx=5, pady=5)
results_label = tk.Label(root, text="Results: ")
results_label.grid(row=8, column=0, padx=5, pady=5)
results_entry = tk.Entry(root, state='normal')
results_entry.grid(row=8, column=1, padx=5, pady=5)

# Run the main loop
root.mainloop()
