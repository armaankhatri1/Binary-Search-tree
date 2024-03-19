.text
.global _start
.extern printf

_start:
    ADR X1, bst  // x1 set to bst space
    ADR X2, inp  // x2 as adrress of input
    ADR X8, inp_len  // x8 set to len of input
    LDR X3, [X8,#0]   // x3 adress of len input
    MOV X4, #0     // x4 index
    MOV X5, #0     //x5 current node


    BL insertion  // call insertion
    BL inordertraverse // call inordertraversal 
              
    SUB SP, SP, #16 // create space on sp
    STUR X30,[SP,#0]  // store x30, link register on stack

    B exit

.func insertion
insertion:

    MOV X21,X1          // save binary search tree 
    MOV X22,X2          // save input array 
    MOV X23,X3          //save input length 
    MOV X24,X4          // save index
    MOV X25,X5          // save parent node
    MOV X26,#3 

    SUB SP, SP, #48   // create space on stack
    STR X21,[SP,#0]   
    STR X22,[SP,#8]
    STR X23,[SP,#16]
    STR X24,[SP,#24]
    STR X25,[SP,#32]
    STR X26,[SP,#40]
    STUR X30,[SP,#48]

    
    BL insertion_more 
    B insertion_done

insertion_more:
    SUB SP, SP, #32      // Allocate space for local variables on the stack
    STR X23, [SP,#0]     // Save X23 (len) on the stack
    STR X24, [SP,#8]     // Save X24 on the stack
    STR X25, [SP,#16]    // Save X25 on the stack
    STUR X30, [SP,#24]   // Save the link register (return address) on the stack

    CBZ X23,staringrec          // Compare len with 0
   

    LDR X9, [X22, X24]   // Load inp[inp_index] into X9
    CMP X24, #0          // Compare inp_index with 0
    B.EQ rootnode        // Branch to rootnode if inp_index == 0
    LDR X10, [X21, X25]  // Load BST[parent_node] into X10
    CMP X9, X10          // Compare inp[inp_index] with BST[parent_node]
    B.EQ insertion_more_done  // Branch to the done if equal
    CMP X9, X10          // Compare inp[inp_index] with BST[parent_node]
    B.LT left         // Branch to setleft if inp[inp_index] < BST[parent_node]
    MOV X11, #16         // Move 16 to X11 (offset for the right child)
    B insertion_more2  // Branch to insertion_more2
left:
    MOV X11, #8

insertion_more2:
    ADD X12, X25, X11       // Calculate address for left child
    LDR X11, [X21, X12]     // Load left child
    CMP X11, -1
    B.GT parentnode

    // If left child is -1, insert the new node as the left child
    MUL X13, X24, X26       // Calculate the address for the new node
    STR X9, [X21, X13]      // Store data in the new node
    STR X13, [X21, X12]     // Set left child pointer
    MOV X14, -1
    ADD X13, X13, #8
    STR X14, [X21, X13]     // Set left child's left child to -1
    ADD X13, X13, #8
    STR X14, [X21, X13]     // Set left child's right child to -1
    B insertion_more_done  // Branch to insertion_more_done

parentnode:
    LDR X23, [SP, #0]
    LDR X24, [SP, #8]
    LDR X25, [SP, #16]
    LDUR X30, [SP, #24]
    ADD SP, SP, #32
    MOV X25, X11
    B insertion_more

staringrec:
    LDUR X30, [SP, #24]
    ADD SP, SP, #32
    BR X30                   // Return to the calling function

rootnode:
    STR X9, [X21, #0]        // Set the root node
    MOV X10, -1
    STR X10, [X21, #8]       // Set left child of the root to -1
    STR X10, [X21, #16]      // Set right child of the root to -1
    B insertion_more_done

insertion_more_done:
    LDR X23, [SP, #0]      // Load len from the stack to X23
    LDR X24, [SP, #8]      // Load inp_index from the stack to X24
    LDR X25, [SP, #16]     // Load parent_node from the stack to X25
    LDUR X30, [SP, #24]    // Load the link register (return address) from the stack to X30
    ADD SP, SP, #32        // Deallocate space for local variables on the stack
    SUB X23, X23, #1       // Decrement len by 1
    ADD X24, X24, #8       // Increment inp_index by 8 (assuming size of int is 8 bytes)
    MOV X25, #0            // Reset parent_node to 0
    B insertion_more     // Branch to insertion_more to continue the insertion process

insertion_done:
    MOV X0, X21             // Move X21 (BST) to X0 for the return value
    LDUR X30, [SP, #48]     // Load the link register (return address) from the stack to X30
    ADD SP, SP, #64         // Deallocate space for local variables on the stack
    BR X30                   // Return from the function
.endfunc


.func inordertraverse
inordertraverse:
    SUB SP, SP, #32        // Allocate space for local variables on the stack
    STR X21, [SP, #0]      // Save X21 on the stack
    STR X22, [SP, #8]      // Save X22 on the stack
    STUR X30, [SP, #16]    // Save the link register (return address) on the stack
    MOV X21, X0            // Move the parameter (BST) to X21
    MOV X22, #0            // Initialize X22 to 0
    BL inordertraverse_more  // Branch to the more function
    B inordertraverse_more_done  // Branch to the done of the function

inordertraverse_more:
    SUB SP, SP, #16        // Allocate space for local variables on the stack
    STR X22, [SP, #0]      // Save X22 on the stack
    STUR X30, [SP, #8]     // Save the link register (return address) on the stack
    ADD X10, X22, #8       // Calculate the address for the next node in the BST
    LDR X10, [X21, X10]    // Load the data of the next node
    CMP X10, -1            // Compare the data with -1
    B.LE printing            // Branch to printing if less than or equal to -1
    MOV X22, X10           // Update X22 with the current node's data
    BL inordertraverse_more  // Recursive call to the left subtree
printing:
    LDR X22, [SP, #0]     // Load X22 (current node's data) from the stack
    ADR X0, output        // Load the address of the format string for printf
    LDR X1, [X21, X22]     // Load the data of the current node
    BL printf             // Call printf to print the current node's data
    ADD X10, X22, #16      // Calculate the address for the next node in the BST
    LDR X10, [X21, X10]    // Load the data of the next node
    CMP X10, -1            // Compare the data with -1
    B.LE inordertraverse_done  // Branch to the done if less than or equal to -1
    MOV X22, X10           // Update X22 with the current node's data
    BL inordertraverse_more  // Recursive call to the left subtree

inordertraverse_done:
    LDR X22, [SP, #0]      // Load X22 from the stack
    LDUR X30, [SP, #8]     // Load the link register (return address) from the stack
    ADD SP, SP, #16        // Deallocate space for local variables on the stack
    BR X30                  // Return from the function

inordertraverse_more_done:
    LDR X21, [SP, #0]      // Load X21 from the stack
    LDR X22, [SP, #8]      // Load X22 from the stack
    LDUR X30, [SP, #16]    // Load the link register (return address) from the stack
    ADD SP, SP, #32        // Deallocate space for local variables on the stack
    BR X30                  // Return from the function
.endfunc


Exit:
    LDUR X30,[SP,#0]
    ADD SP, SP, #16
    MOV X0, #0
    MOV w8, #93
    SVC #0

.data   
inp:
    .dword 4,14,26,1,7,19 // works with multple values up to 32
inp_len:
    .dword 6   
output:
    .ascii "%d\n\0"
.bss
bst:
    .space 768   // 32(values) * 3(spaces, parent,L child, R child) * 8(bytes) = 768
.end
