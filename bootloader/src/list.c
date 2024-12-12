#include "list.h"
#include "lib.h"
void append(list_t *list, node_t *node)
{
    node_t *current = list->head;
    while (current != NULL)
    {
        if (current == node)
        {
            printf("Node is already in the list. Not appending.\n");
            return; // Node is already in the list, so return early
        }
        current = current->next;
    }

    // if the lists head is null set a new head
    if (list->head == NULL)
    {
        list->head = node;
        node->prev = NULL;
        node->next = NULL;
    }
    else
    {
        // else traverse to the end of the list and append the new node
        node_t *current = list->head;
        while (current->next != NULL)
        {
            current = current->next;
        }
        current->next = node;
        node->prev = current;
        node->next = NULL;
    }
}

void delete(list_t *list, node_t *node)
{
    // Check if the node is actually in the list
    node_t *current = list->head;
    while (current != NULL)
    {
        if (current == node)
        {
            // Node found, proceed to delete

            // If the node is the first in the list (head), update the head pointer
            if (node == list->head)
            {
                list->head = node->next;
            }

            // If the node is not the first node, update the previous node's next pointer
            if (node->prev != NULL)
            {
                node->prev->next = node->next;
            }

            // If the node is not the last node, update the next node's prev pointer
            if (node->next != NULL)
            {
                node->next->prev = node->prev;
            }
            node->next = NULL;
            node->prev = NULL;

            return;
        }

        current = current->next; // Move to the next node
    }

    // If we reach here, the node wasn't found in the list
    printf("Node not found in the list.\n");
}

void dump_list(list_t *list)
{

    node_t *node;
    FOR_EACH(list, node)
    {
        printf("%d\n", *(int *)node->data);
    }
}
void test_list_operations()
{
    list_t list = LIST_INIT(list_t);

    node_t node1 = NODE_INIT(node_t);
    int data1 = 69;
    node1.data = &data1;

    node_t node2 = NODE_INIT(node_t);
    int data2 = 88;
    node2.data = &data2;

    node_t node3 = NODE_INIT(node_t);
    int data3 = 1914;
    node3.data = &data3;

    append(&list, &node1);
    append(&list, &node2);

    dump_list(&list);
}