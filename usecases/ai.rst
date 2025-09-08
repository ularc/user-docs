AI Use Cases
############

Pneumonia detection based on Chest X-Ray
========================================

.. note::

  This use case is still a work in progress. We will be
  adding more information in the coming days and this message will be
  removed once it's completely documented. Thank you for your patience.

This use-case is adapted from the Kaggle notebook
`Chest X-Ray (Pneumonia) - CNN & Transfer Learning <https://www.kaggle.com/code/jonaspalucibarbosa/chest-x-ray-pneumonia-cnn-transfer-learning/notebook>`_.

The purpose of the notebook is to apply Convolutional Neural Networks (CNNs) to Chest X-Ray images in order to identify cases of Pneumonia.
The dataset used is version 3 of the `Chest X-ray Images <https://www.kaggle.com/datasets/tolgadincer/labeled-chest-xray-images>`_, which includes separate folders for training and testing.
Within the notebook, the training set is further split into training and validation subsets.

Three approaches are explored for image classification:

1. Basic CNN architecture - A simple model built from scratch.
2. Transfer Learning - Using a pretrained model with frozen layers to extract features.
3. Fine-Tuning - Unfreezing the final layers of the pretrained model to improve performance.

To run the notebook's code in LARCC, you can:

1. Download the notebook from Kaggle, launch an instance of jupyter as described :ref:`here <jupyter>` and load the notebook in Jupyter.
2. Convert the notebook into a python script and run it through a batch or interactive job.

Option 2 offers added benefits like the abilty to speed-up the training of your models, consuming less memory and even creating pipelines
where multiple models can be trained at the same time.

There is, however, a slight problem no matter which option is chosen. The code uses an older version of tensorflow and thus must
be adapted to ensure it runs properly at the training phase.

Let's start by getting acquinted with the data. When you download and unzip the dataset from kaggle, you end up with 2 folders.
One that has all the images related to training and validation, and the other has images for testing.
For example, assuming the user ``jd01`` stored the data in ``/home/jd01/chest_xray``, the directory structure would
look as below:

.. figure:: images/chest-xray/dataset_structure.png
   :width: 600
   :alt: kaggle_dataset_Structure

The ``train`` folder has 5232 images total, out of which 1349 are from healthy patients and 3883 from sick patients.
The ``test`` folder has 624 images total, out of which 234 are from healthy patients and 390 from sick patients. Following
the example, ``jd01`` can corroborate these numbers as follows: 

.. code-block:: python

  import os
  import glob

  main_path = "/home/jd01/chest_xray"
  train_path = os.path.join(main_path,"train")
  test_path=os.path.join(main_path,"test")

  train_normal = glob.glob(train_path+"/NORMAL/*.jpeg")
  train_pneumonia = glob.glob(train_path+"/PNEUMONIA/*.jpeg")

  test_normal = glob.glob(test_path+"/NORMAL/*.jpeg")
  test_pneumonia = glob.glob(test_path+"/PNEUMONIA/*.jpeg")

  num_img_train = len(train_normal) + len(train_pneumonia)
  num_img_test = len(train_normal) + len(train_pneumonia)

  print(f"Number of healthy patients in {train_path}: {len(train_normal)}" )
  print(f"Number of sick patients in {train_path}: {len(train_pneumonia)}" )
  print(f"Total number of images in {train_path}: {num_img_train}")

  print(f"Number of healthy patients in {test_path}: {len(test_normal)}" )
  print(f"Number of sick patients in {test_path}: {len(test_pneumonia)}" )
  print(f"Total number of images in {test_path}: {num_img_test}")

Better yet, further exploration of the data can be achieved by making these image paths into dataframes:

.. code-block:: python

  import pandas as pd
  import numpy as np

  train_list = [x for x in train_normal]
  train_list.extend([x for x in train_pneumonia])

  df_train = pd.DataFrame(np.concatenate([['Normal']*len(train_normal) , ['Pneumonia']*len(train_pneumonia)]), columns = ['class'])
  df_train['image'] = [x for x in train_list]

  test_list = [x for x in test_normal]
  test_list.extend([x for x in test_pneumonia])

  df_test = pd.DataFrame(np.concatenate([['Normal']*len(test_normal) , ['Pneumonia']*len(test_pneumonia)]), columns = ['class'])
  df_test['image'] = [x for x in test_list]

which can then be used to visualize its distribution:

.. list-table:: 

    * - .. figure:: images/chest-xray/train_data_dist_barplot.png
           :scale: 70%

           Training data sample distribution

      - .. figure:: images/chest-xray/test_data_dist_barplot.png
           :scale: 70%

           Test data sample distribution
    * - .. figure:: images/chest-xray/train_data_dist_pieplot.png
           :scale: 70%

           Training data percentual distribution

      - .. figure:: images/chest-xray/test_data_dist_pieplot.png
           :scale: 70%

           Test data percentual distribution

Before creating the model, we need to load all the images from the ``train`` and ``test`` folders into our program. For the training data, we split it into 2 groups. 
One group contains 20% of the images (i.e 0.20*5232 ~= 1046) and is used for validation purposes (i.e. ``ds_val`` in the code below)
while the other 80% (i.e. 5232 - 1046 = 4186) is used for training (i.e. ``ds_train``):

.. code-block:: python

  import tensorflow as tf

  IMG_SIZE = 224
  BATCH = 32
  SEED = 42
  VALIDATION_SPLIT = 0.20
  TRAINING_SPLIT = 1 - VALIDATION_SPLIT

  classes = [ 'NORMAL', 'PNEUMONIA' ]

  ds_train, ds_val = tf.keras.utils.image_dataset_from_directory(
    train_path,
    class_names = classes,
    labels = 'inferred',
    label_mode = 'binary',
    image_size = (IMG_SIZE, IMG_SIZE),
    batch_size = BATCH,
    seed = SEED,
    validation_split = VALIDATION_SPLIT,
    subset='both'
  )

  ds_test = tf.keras.utils.image_dataset_from_directory(
    test_path,
    class_names = classes,
    labels = 'inferred',
    label_mode = 'binary',
    image_size = (IMG_SIZE, IMG_SIZE),
    batch_size = 1,
    seed = SEED,
    shuffle = False
  )

note that by using ``subset='both'`` we indicate to ``tf.keras.utils.image_dataset_from_directory`` that we want it
to return a tuple of two datasets, the training and validation datasets respectively.

Then, we'll pre-process the images to make them better suited for training. The original code transforms
the datasets with ``tf.keras.preprocessing.image.ImageDataGenerator``, but
we'll follow a different approach and use ``tensorflow.keras.layers``:

.. code-block:: python

  from tensorflow import keras
  from tensorflow.keras import layers

  AUTOTUNE = tf.data.experimental.AUTOTUNE
  
  normalization_layer = layers.Rescaling(1./255)
  # To achieve a similar zoom range as ImageDataGenerator(zoom_range=0.1)
  # which is [0.9, 1.1] zoom factor.
  # The RandomZoom layer takes fractional factors, so -0.1 to 0.1 means
  # 1 - 0.1 to 1 + 0.1 zoom.
  zoom_layer = layers.RandomZoom(height_factor=(-0.1, 0.1), width_factor=(-0.1, 0.1))
  resize_layer = layers.RandomTranslation(height_factor=0.1, width_factor=0.1)

  ds_train = ds_train.map(lambda x, y: (normalization_layer(x), y), num_parallel_calls=AUTOTUNE)
  ds_train = ds_train.map(lambda x, y: (zoom_layer(x), y), num_parallel_calls=AUTOTUNE)
  ds_train = ds_train.map(lambda x, y: (resize_layer(x), y), num_parallel_calls=AUTOTUNE)

  ds_val = ds_val.map(lambda x, y: (normalization_layer(x), y), num_parallel_calls=AUTOTUNE)

  ds_test = ds_test.map(lambda x, y: (normalization_layer(x), y), num_parallel_calls=AUTOTUNE)

At this point, we are ready to start defining and training the models.

.. code-block:: python

  import math

  num_training_steps = math.ceil((num_img_train * TRAINING_SPLIT)/BATCH)
  num_validation_steps = math.ceil((num_img_train * VALIDATION_SPLIT)/BATCH)

CNN Training and Valididation
------------------------------

.. code-block:: python

  from tensorflow.keras import callbacks
  from tensorflow.keras.models import Model

  class ColorChannel:
    GREYSCALE = 1
    RGB = 3
    RGBA = 4

  def get_uncompiled_model(img_width, img_height, color_channel):
      inputs = layers.Input(shape=(img_width, img_height, color_channel))

      # Block One
      x = layers.Conv2D(filters=16, kernel_size=3, padding='valid')(inputs)
      x = layers.BatchNormalization()(x)
      x = layers.Activation('relu')(x)
      x = layers.MaxPool2D()(x)
      x = layers.Dropout(0.2)(x)

      # Block Two
      x = layers.Conv2D(filters=32, kernel_size=3, padding='valid')(x)
      x = layers.BatchNormalization()(x)
      x = layers.Activation('relu')(x)
      x = layers.MaxPool2D()(x)
      x = layers.Dropout(0.2)(x)

      # Block Three
      x = layers.Conv2D(filters=64, kernel_size=3, padding='valid')(x)
      x = layers.Conv2D(filters=64, kernel_size=3, padding='valid')(x)
      x = layers.BatchNormalization()(x)
      x = layers.Activation('relu')(x)
      x = layers.MaxPool2D()(x)
      x = layers.Dropout(0.4)(x)

      # Head
      #x = layers.BatchNormalization()(x)
      x = layers.Flatten()(x)
      x = layers.Dense(64, activation='relu')(x)
      x = layers.Dropout(0.5)(x)

      #Final Layer (Output)
      output = layers.Dense(1, activation='sigmoid')(x)

      model = keras.Model(inputs=[inputs], outputs=output)

      return model
  
  early_stopping = callbacks.EarlyStopping(
    monitor='val_loss',
    patience=5,
    min_delta=1e-7,
    restore_best_weights=True,
  )

  plateau = callbacks.ReduceLROnPlateau(
      monitor='val_loss',
      factor = 0.2,                                     
      patience = 2,                                   
      min_delt = 1e-7,                                
      cooldown = 0,                               
      verbose = 1
  )

  cnn_model = get_uncompiled_model(IMG_SIZE, IMG_SIZE, ColorChannel.RGB)
  cnn_model.compile(loss='binary_crossentropy'
                , optimizer = keras.optimizers.Adam(learning_rate=3e-5)
                , metrics=['binary_accuracy'])
  
  cnn_training_history = cnn_model.fit(
    ds_train,
    batch_size = BATCH, epochs = 50,
    validation_data=ds_val,
    callbacks=[early_stopping, plateau],
    steps_per_epoch=(math.ceil(len(train_df)/BATCH)),
    validation_steps=(math.ceil(len(val_df)/BATCH))
  )

  score = model.evaluate(ds_val, steps = math.ceil(len(val_df)/BATCH), verbose = 0)
  print('(CNN) Val loss:', score[0])
  print('(CNN) Val accuracy:', score[1])

.. list-table:: 

    * - .. figure:: images/chest-xray/cnn_learning_curve_accuracy.png
           :scale: 70%

           Accuracy of CNN

    * - .. figure:: images/chest-xray/cnn_learning_curve_loss.png
           :scale: 70%

           Loss of CNN
    * - .. figure:: images/chest-xray/tl_learning_curve_accuracy.png
           :scale: 70%

           Accuracy of Transfer Learning

    * - .. figure:: images/chest-xray/tl_learning_curve_loss.png
           :scale: 70%

           Loss of Transfer Learning
    * - .. figure:: images/chest-xray/ft_learning_curve_accuracy.png
           :scale: 70%

           Accuracy of Fine Tuning

    * - .. figure:: images/chest-xray/tl_learning_curve_loss.png
           :scale: 70%

           Loss of Fine Tuning

Med-BERT
========

The Med-BERT model is a natural language processing model for disease prediction based on EHR records.
You can read more about it in the paper:

    *Laila Rasmy, Yang Xiang, Ziqian Xie, Cui Tao, and Degui Zhi. "Med-BERT: pre-trained contextualized embeddings on large-scale structured electronic health records for disease prediction." npj digital medicine 2021* `<https://www.nature.com/articles/s41746-021-00455-y>`_.

Due to vendor restrictions, the authors could not share their trained model:

    *Initially we really hoped to share our models but unfortunately, the pre-trained models are no longer sharable. According to SBMI Data Service Office: "Under the terms of our contracts with data vendors, we are not permitted to share any of the data utilized in our publications, as well as large models derived from those data."*

but they shared code to reproducte Med-BERT at `<https://github.com/ZhiGroup/Med-BERT>`_.

If you have access to data that aligns with Med-BERT's requirements, you can leverage LARCC's resources to create your own instance of Med-BERT.
Here is an example for the pre-training phase:

#. Setup code dependencies. For this case, the pretraining code depends on tensorflow 1.x, which

    - is only compatible with python 3.5 to 3.7. The cluster comes with python 3.9 by default and, currently, there is no module for any
      of these python versions. Thus, you will need to use :ref:`Conda <conda>` to create an environment with the desired python version.
    - is compatible with protobuf versions prior 4.0.
    - is compatible with cuda versions up to CUDA 10. LARCC's gpus are only compatible with CUDA versions greater than 11.8, so you will need to
      use CPUs for the pretraining.

    .. code-block:: bash

        module load miniforge3
        conda create --name my_tf1 python=3.7 tensorflow-gpu 'protobuf<=3.20' pandas numpy matplotlib

#. Download code and rename all spaces in folder names with ``_`` to avoid conflicts in Linux.

    .. code-block:: bash

        cd ~
        git clone https://github.com/ZhiGroup/Med-BERT.git
        find Med-BERT -type d -name '*[[:space:]]*' | xargs -I '{}' sh -c "mv '{}' \`echo '{}' | sed 's/ /_/g'\`"

#. Preprocess the data you will use for the pretraining step. In the example below, the option ``--output_file='ehr_tf_features'``
   will create a tensorflow formatted features file named ``ehr_tf_features`` required for the pretraining.

    .. code-block:: bash

        cd ~/Med-BERT/Pretraining_Code/Data_Pre-processing_Code
        # NOTE: You can do the following on a batch job instead.
        srun --partition=compute --job-name med-bert --time=01:00:00 --ntasks-per-node=128 --cpu-bind=cores --pty /bin/bash -i
        cd ~/Med-BERT/Pretraining_Code/Data_Pre-processing_Code
        module load miniforge3
        conda activate my_tf1
        # NOTE: This assumes your input file is stored in the path below. Change it to something
        # else if you store your data somewhere else
        INPUT=~/Med-BERT/Pretraining_Code/Data_Pre-processing_Code/data_file.tsv
        OUT_PREFIX=preprocessed
        python3 preprocess_pretrain_data.py "$INPUT" NA "$OUT_PREFIX"
        python3 create_BERTpretrain_EHRfeatures.py \
            --input_file="$OUT_PREFIX.bencs.train" \
            --output_file='ehr_tf_features' \
            --vocab_file="$OUT_PREFIX.types" \
            --max_predictions_per_seq=1 \
            --max_seq_length=64
        exit

#. Create a submission script for the pretraining phase. Assume the script below is written to ``~/med-bert.sbatch``.

    .. note::

        You may want to perform some preliminary runs with smaller values for The
        ``--num_train_steps`` and ``--num_warmup_steps`` options where you tweak the number of cores
        on each run. The idea is to find the optimal number of cores to use as too many cores does not
        always guarantee better performance. For example, using the provided example data file from
        the Med-BERT repo:
        
        .. list-table:: Pretraining of Med-BERT example data with ``--num_train_steps=4500`` and ``--num_warmup_steps=1000``
           :widths: 10 10
           :align: center
           :header-rows: 1

           * - Cores
             - Time
           * - 128
             - 15m36.219s
           * - 64
             - 12m36.336s
           * - 32
             - 18m28.998s
           * - 12
             - 19m52.057s

    .. literalinclude:: scripts/med-bert.sbatch
     :language: bash
     :linenos:

#. Submit script to slurm with ``sbatch ~/med-bert.sbatch``.