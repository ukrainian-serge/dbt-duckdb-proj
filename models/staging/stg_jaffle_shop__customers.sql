WITH source AS (
    SELECT *
    FROM
        {{ source(
            'jaffle_shop',
            'customers'
        ) }}
),

cleaned AS (
    SELECT
        id AS customer_id,
        TRIM(
            REGEXP_REPLACE(
                REGEXP_REPLACE(name, '[^a-zA-Z\s]', ''),
                '\s+',
                ' '
            )
        ) AS clean_name
    FROM
        source
),

tokens AS (
    SELECT
        customer_id,
        {{ string_split_array('clean_name', "' '") }} AS name_parts,
        ARRAY_LENGTH({{ string_split_array('clean_name', "' '") }}) AS part_count
    FROM
        cleaned
),

final AS (
    SELECT
        customer_id,
        
        -- First Name: First item (if present)
        CASE 
            WHEN part_count >= 1 THEN name_parts[1]
            ELSE NULL 
        END AS first_name,
        
        -- Middle Name: Assigned ONLY if the array has 3 or more items
        CASE 
            WHEN part_count >= 3 THEN name_parts[2]
            ELSE NULL 
        END AS middle_name,
        
        -- Last Name: 
        -- If 2 parts: item at index 2 (second element, 1-based indexing)
        -- If 3+ parts: joins everything from index 3 onwards
        CASE 
            WHEN part_count = 2 THEN name_parts[2]
            WHEN part_count >= 3 THEN {{ array_concat_string('array_slice(name_parts, 3, -1)', "' '") }}
            ELSE NULL 
        END AS last_name

    FROM
        tokens
)

SELECT *
FROM final
