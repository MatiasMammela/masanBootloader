#ifndef LIST_H
#define LIST_H
#include <stddef.h>
#define LIST_INIT(list_t) {.head = NULL}
#define NODE_INIT(node_t) {.next = NULL, .prev = NULL}
#define FOR_EACH(list, node) \
    for (node = list->head; node != NULL; node = node->next)

typedef struct node_t
{
    void *data;
    struct node_t *next;
    struct node_t *prev;
} node_t;

typedef struct list_t
{
    struct node_t *head;
} list_t;

void append(list_t *list, node_t *node);
void dump_list(list_t *list);
#endif // LIST_H