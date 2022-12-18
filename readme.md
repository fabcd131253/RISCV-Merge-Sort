# Merge Sort implemented by RISC-V assembly code
 > This readme is written in Traditional Chinese, encoding in UTF-8.

 此程式將儲存於 `.data` 中的數列，以 Merge Sort 的方式使其升冪排序。
 
### 撰寫環境
 - RV32I Base, no extensions
 - Windows 10
 
### 資料儲存方式

 - `.data` 以記憶體中的 `0x10000000` 為起始點。
 - `0x10000000` 至 `0x10000003` 存放數列的總數（共有 n 個數列）。
 - `0x10000004` 至 `0x10000004 + 4n - 1` 存放各數列的長度。
 - `0x1000004 + 4n` 以後存放各數列（詳細存放方式可參考程式碼）。

### 程式使用方式

 - 將需要排序的數列及資訊以規定的方式儲存至 `.data` 中，執行程式後即可完成排序。排序後的結果存放在記憶體中的 `0x01000000` 處。

### 注意事項
 - 因為在陣列中，一個整數的儲存空間為 4bytes，移動 1 index 即為移動 4bytes，所以在 `merge` 中，所有操作 index 的數字都將改為 4 的倍數。

 - 在 `merge` 中，由於 `temp[]` 儲存於記憶體中的 stack，而 stack 的 bottom 在記憶體的上層，top 在記憶體的下層，所以在操作 `temp[]` 的 index 時，需要將加法改為減法。

 - 在 `merge_sort` 中，由於是連續 branch 至三個 functions，所以在其間不需要重新 allocate stack memory，只需要讀取儲存在 stack 中的數值，並進行下一次的 branch 即可。

### References

 - [RISC-V Instruction Set Manual](https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf)


 > This work is licensed under a
[Creative Commons Attribution 4.0 International License][cc-by].
[![CC BY 4.0][cc-by-image]][cc-by]

[cc-by]: http://creativecommons.org/licenses/by/4.0/
[cc-by-image]: https://i.creativecommons.org/l/by/4.0/88x31.png